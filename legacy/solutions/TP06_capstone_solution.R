# ARCHIVE FACULTATIVE — ancien parcours à six TP, hors tronc commun de 18 h.
# Corrigé TP06 autonome — aucun source() des fonctions de référence.
# Depuis la racine : Rscript legacy/solutions/TP06_capstone_solution.R
# Question : quelle différence de durée moyenne (B-A) dans les tickets observés ?
if (!file.exists("course.Rproj")) stop("Exécuter depuis la racine du projet.")
raw <- read.csv("data/noria_dirty.csv", stringsAsFactors = FALSE, na.strings = "",
                colClasses = c("integer", "character", "numeric", "numeric", "numeric", "character"), fileEncoding = "UTF-8")
d <- raw
trimmed <- sum(d$workflow != trimws(d$workflow)) + sum(d$team != trimws(d$team))
d$workflow <- trimws(d$workflow)
d$team <- trimws(d$team)
# Les domaines se valident avant les exclusions de durée, pour ne rien dissimuler.
stopifnot(!anyNA(d$ticket_id), all(is.finite(d$ticket_id)), all(d$ticket_id > 0),
          all(d$ticket_id == floor(d$ticket_id)), !anyNA(d$workflow), !anyNA(d$team),
          all(d$workflow %in% c("A", "B")), all(d$team %in% c("Atlas", "Boreal", "Cedre")),
          !anyNA(d$complexity), all(d$complexity %in% 1:5),
          all(is.na(d$satisfaction) | d$satisfaction %in% 1:5))
duplicates <- duplicated(d$ticket_id)
# Règle du cas : seul un doublon exact peut être retiré automatiquement.
for (i in which(duplicates)) {
  if (!isTRUE(all.equal(d[i, ], d[match(d$ticket_id[i], d$ticket_id), ], check.attributes = FALSE))) {
    stop("Doublon conflictuel : investigation nécessaire.")
  }
}
d <- d[!duplicates, ]
missing <- is.na(d$resolution_minutes)
invalid <- !missing & (!is.finite(d$resolution_minutes) | d$resolution_minutes <= 0)
exclusions <- data.frame(ticket_id = d$ticket_id[missing | invalid],
                         reason = ifelse(missing[missing | invalid], "missing_outcome", "invalid_outcome"))
audit <- data.frame(metric = c("raw_rows", "trimmed_label_cells", "duplicate_rows_removed",
                               "missing_outcomes_removed", "invalid_outcomes_removed", "clean_rows",
                               "satisfaction_missing_retained"),
                     count = c(nrow(raw), trimmed, sum(duplicates), sum(missing), sum(invalid),
                               sum(!missing & !invalid), sum(is.na(d$satisfaction[!missing & !invalid]))))
d <- d[!missing & !invalid, ]
d$workflow <- factor(d$workflow, levels = c("A", "B"))
d$team <- factor(d$team, levels = c("Atlas", "Boreal", "Cedre"))
stopifnot(nrow(d) == 236L, !anyDuplicated(d$ticket_id), !anyNA(d$workflow), !anyNA(d$team),
          sum(is.na(d$satisfaction)) == 12L, all(d$resolution_minutes > 0),
          all(d$complexity %in% 1:5), all(is.na(d$satisfaction) | d$satisfaction %in% 1:5))
# Description : distribution, médiane, dispersion, puis test de l'écart moyen.
groups <- split(d$resolution_minutes, d$workflow)
summary_table <- data.frame(workflow = names(groups),
                            n = vapply(groups, length, integer(1)),
                            mean_minutes = vapply(groups, mean, numeric(1)),
                            sd_minutes = vapply(groups, sd, numeric(1)),
                            median_minutes = vapply(groups, median, numeric(1)))
welch <- t.test(x = groups$B, y = groups$A, var.equal = FALSE)
contrast <- data.frame(contrast = "B - A", estimate_minutes = mean(groups$B) - mean(groups$A),
                        conf_low = unname(welch$conf.int[1]), conf_high = unname(welch$conf.int[2]),
                        p_value = welch$p.value)
# Modèle ajusté additif : le coefficient workflowB conserve l'orientation B-A.
model <- lm(resolution_minutes ~ workflow + complexity + team, data = d)
model_summary <- coef(summary(model))
model_intervals <- confint(model)
coefficients <- data.frame(term = rownames(model_summary), estimate = model_summary[, 1],
                            std_error = model_summary[, 2], p_value = model_summary[, 4],
                            conf_low = model_intervals[, 1], conf_high = model_intervals[, 2],
                            row.names = NULL)
diagnostics <- data.frame(ticket_id = d$ticket_id, fitted = fitted(model),
                           residual = residuals(model), cooks_distance = cooks.distance(model))
# Réduction locale : les trois lots n'ont pas la même taille.
parts <- split(d$resolution_minutes, c(rep(1, 7), rep(2, 53), rep(3, 176)))
sums <- vapply(parts, sum, numeric(1))
counts <- vapply(parts, length, integer(1))
weighted_mean <- sum(sums) / sum(counts)
stopifnot(abs(weighted_mean - mean(d$resolution_minutes)) < 1e-10)
output <- file.path("results", "capstone")
dir.create(output, recursive = TRUE, showWarnings = FALSE)
exports <- list(clean = d, audit = audit, exclusions = exclusions, summary = summary_table,
                welch_B_minus_A = contrast, model_coefficients = coefficients, model_diagnostics = diagnostics,
                mapreduce = data.frame(partition = names(parts), sum = sums, count = counts, mean = sums / counts),
                mapreduce_comparison = data.frame(method = c("weighted", "mean_of_means_incorrect"),
                                                  mean_minutes = c(weighted_mean, mean(sums / counts))))
for (name in names(exports)) {
  write.csv(exports[[name]], file.path(output, paste0(name, ".csv")), row.names = FALSE, na = "")
}
pdf(file.path(output, "eda.pdf"), width = 8, height = 4)
par(mfrow = c(1, 2))
hist(d$resolution_minutes, main = "Distribution des durees", xlab = "Minutes")
boxplot(resolution_minutes ~ workflow, data = d, ylab = "Minutes", main = "Workflows A et B")
dev.off()
pdf(file.path(output, "diagnostics.pdf"), width = 8, height = 7)
par(mfrow = c(2, 2))
plot(model, which = c(1, 2, 3, 5))
dev.off()
capture.output(sessionInfo(), file = file.path(output, "sessionInfo.txt"))
print(audit, row.names = FALSE)
print(summary_table, row.names = FALSE)
print(contrast, row.names = FALSE)
print(coefficients, row.names = FALSE)
# Attendus : A117/B119 ; B-A=-4.5647848883 min ; moyenne globale68.3529661017.
# Welch : IC95%[-9.1476483068 ; 0.0180785301], p=0.05090316485.
# Modèle : workflowB=-5.1497687759 ; IC95%[-8.4179115974 ; -1.8816259543].
# Le modèle préspécifié ajuste sur la complexité : sa précision diffère du test brut.
# Ne pas sélectionner une analyse après avoir comparé ses p-valeurs.
# Décision : quantifier le gain simulé et son incertitude, examiner le modèle,
# puis proposer une collecte réelle avec protocole d'exclusion fixé à l'avance.
# La simulation n'est pas une preuve de gain commercial pour Noria.
