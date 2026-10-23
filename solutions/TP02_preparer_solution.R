# TP02 — Corrigé commenté : préparer · durée indicative : 120 min · R de base, depuis la racine du projet.
# 1. Ouvrez course.Rproj ; ouvrez ce fichier dans l'éditeur.
# 2. Exécutez une ligne à la fois pour relier le calcul à sa justification.
# 3. Relancez ensuite le corrigé entier dans une session R neuve.
# 4. Lancez source("checks/TP02.R", encoding = "UTF-8").
# Résultat final attendu du contrôle : « TP02 : contrôles réussis. »
# Les contrôles en fin de script vérifient les objets et les fichiers produits.
# Voir le PDF 11_TP02_preparer.pdf pour les calculs à la main et les critères de réussite.

raw <- read.csv("data/noria_dirty.csv", na.strings = c("", "NA"),
  stringsAsFactors = FALSE, fileEncoding = "UTF-8",
  colClasses = c("integer", "character", "numeric", "numeric", "numeric", "character"))
# Chaque règle a sa ligne d'audit ; le brut reste intact.
d <- raw
audit <- data.frame(etape = "import", n_avant = nrow(raw), n_apres = nrow(raw),
                    n_exclues = 0L, n_cellules_modifiees = 0L)
n_espaces_workflow <- sum(d$workflow != trimws(d$workflow))
n_espaces_team <- sum(d$team != trimws(d$team))
d$workflow <- trimws(d$workflow)
d$team <- trimws(d$team)
audit <- rbind(audit, data.frame(etape = "espaces", n_avant = nrow(d),
  n_apres = nrow(d), n_exclues = 0L,
  n_cellules_modifiees = n_espaces_workflow + n_espaces_team))
# Une ligne est une observation : d[lignes, colonnes]. La virgule garde toutes les colonnes.
# Le ticket 17 répète exactement ses valeurs. En cas de conflit, enquêter avant d'exclure.
doublons <- duplicated(d$ticket_id)
# Pour chaque répétition, comparer toutes les valeurs à la première occurrence.
# On ignore seulement les noms de lignes ; une différence de contenu impose un arrêt.
for (i in which(doublons)) {
  premier <- match(d$ticket_id[i], d$ticket_id)
  if (!isTRUE(all.equal(d[i, , drop = FALSE], d[premier, , drop = FALSE],
                       check.attributes = FALSE))) {
    stop(sprintf("Doublon conflictuel pour le ticket %s : enquêter avant de supprimer.",
                 d$ticket_id[i]))
  }
}
ids_doublons <- d$ticket_id[doublons]
n_avant <- nrow(d)
d <- d[!doublons, , drop = FALSE]
audit <- rbind(audit, data.frame(etape = "doublons", n_avant = n_avant,
  n_apres = nrow(d), n_exclues = sum(doublons), n_cellules_modifiees = 0L))
absentes <- is.na(d$resolution_minutes)
ids_absents <- d$ticket_id[absentes]
exclusions <- data.frame(ticket_id = ids_absents, motif = "duree_absente")
n_avant <- nrow(d)
d <- d[!absentes, , drop = FALSE]
audit <- rbind(audit, data.frame(etape = "durees_absentes", n_avant = n_avant,
  n_apres = nrow(d), n_exclues = sum(absentes), n_cellules_modifiees = 0L))
invalides <- !is.finite(d$resolution_minutes) | d$resolution_minutes <= 0
ids_invalides <- d$ticket_id[invalides]
exclusions <- rbind(exclusions, data.frame(ticket_id = ids_invalides, motif = "duree_invalide"))
n_avant <- nrow(d)
d <- d[!invalides, , drop = FALSE]
audit <- rbind(audit, data.frame(etape = "durees_invalides", n_avant = n_avant,
  n_apres = nrow(d), n_exclues = sum(invalides), n_cellules_modifiees = 0L))
stopifnot(all(d$workflow %in% c("A", "B")), all(d$team %in% c("Atlas", "Boreal", "Cedre")))
d$workflow <- factor(d$workflow, levels = c("A", "B"))
d$team <- factor(d$team, levels = c("Atlas", "Boreal", "Cedre"))
audit <- rbind(audit, data.frame(etape = "facteurs", n_avant = nrow(d),
  n_apres = nrow(d), n_exclues = 0L, n_cellules_modifiees = 0L))
rownames(d) <- NULL
clean <- d
# Satisfaction absente ne signifie pas durée absente ; on conserve ces 12 tickets.
n_satisfaction_absente <- sum(is.na(clean$satisfaction))
# Fonction courte : son argument x est un vecteur de durées valides.
resumer_durees <- function(x) {
  c(n = length(x), moyenne = mean(x), ecart_type = sd(x),
    q1 = unname(quantile(x, 0.25, type = 7)), mediane = median(x),
    q3 = unname(quantile(x, 0.75, type = 7)))
}
# Deux appels explicites : mêmes calculs dans les deux groupes.
descriptifs <- rbind(
  data.frame(workflow = "A", as.list(resumer_durees(clean$resolution_minutes[clean$workflow == "A"]))),
  data.frame(workflow = "B", as.list(resumer_durees(clean$resolution_minutes[clean$workflow == "B"]))))
dir.create("results", showWarnings = FALSE)
write.csv(clean, "results/TP02_clean.csv", row.names = FALSE)
write.csv(audit, "results/TP02_audit.csv", row.names = FALSE)
write.csv(exclusions, "results/TP02_exclusions.csv", row.names = FALSE)
write.csv(descriptifs, "results/TP02_descriptifs.csv", row.names = FALSE)
pdf("results/TP02_graphiques.pdf", width = 8, height = 5)
boxplot(resolution_minutes ~ workflow, data = clean,
  xlab = "Workflow", ylab = "Durée de résolution (minutes)", main = "Noria : durées par workflow")
hist(clean$resolution_minutes, xlab = "Durée de résolution (minutes)",
  main = "Noria : distribution des durées", col = "grey85")
dev.off()
source("checks/TP02.R", local = TRUE, encoding = "UTF-8")
