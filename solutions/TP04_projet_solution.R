# TP04 — Corrigé commenté : projet · durée indicative : 150 min · R de base, depuis la racine du projet.
# 1. Ouvrez course.Rproj ; ouvrez ce fichier dans l'éditeur.
# 2. Exécutez une ligne à la fois pour relier le calcul à sa justification.
# 3. Relancez ensuite le corrigé entier dans une session R neuve.
# 4. Lancez source("checks/TP04.R", encoding = "UTF-8").
# Résultat final attendu du contrôle : « TP04 : contrôles réussis. »
# Les contrôles en fin de script vérifient les objets et les fichiers produits.
# Voir le PDF 13_TP04_projet.pdf pour les calculs à la main et les critères de réussite.

# Ce script repart du brut ; il ne charge aucun fichier de référence ni ancien résultat.
raw4 <- read.csv("data/noria_dirty.csv", na.strings = c("", "NA"), stringsAsFactors = FALSE,
  colClasses = c("integer", "character", "numeric", "numeric", "numeric", "character"))
nettoyer_projet <- function(brut) {
# Chaque règle a sa ligne d'audit ; le brut reste intact.
d <- brut
audit <- data.frame(etape = "import", n_avant = nrow(brut), n_apres = nrow(brut),
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
  list(data = clean, audit = audit, exclusions = exclusions)
}
lot4 <- nettoyer_projet(raw4)
clean4 <- lot4$data
audit4 <- lot4$audit
exclusions4 <- lot4$exclusions
decrire_projet <- function(donnees) {
  resumer <- function(x) c(n = length(x), moyenne = mean(x), ecart_type = sd(x),
    q1 = unname(quantile(x, .25, type = 7)), mediane = median(x),
    q3 = unname(quantile(x, .75, type = 7)))
  rbind(data.frame(workflow = "A", as.list(resumer(donnees$resolution_minutes[donnees$workflow == "A"]))),
        data.frame(workflow = "B", as.list(resumer(donnees$resolution_minutes[donnees$workflow == "B"]))))
}
descriptifs4 <- decrire_projet(clean4)
a4 <- clean4$resolution_minutes[clean4$workflow == "A"]
b4 <- clean4$resolution_minutes[clean4$workflow == "B"]
test4 <- t.test(b4, a4, var.equal = FALSE, conf.level = .95)
comparaison4 <- data.frame(contraste = "B - A", delta_minutes = mean(b4) - mean(a4),
  ic_bas = unname(test4$conf.int[1]), ic_haut = unname(test4$conf.int[2]), p_valeur = test4$p.value)
seuil_utile4 <- 5
# Critère fixé par le protocole pédagogique, sans prétendre à un préenregistrement.
# Ces branches adaptent la décision à l'intervalle obtenu.
if (comparaison4$ic_haut < -seuil_utile4) {
  zone_decision4 <- "gain_etaye"
  decision4 <- "Le gain utile est étayé ; proposer un déploiement progressif avec suivi."
} else if (comparaison4$ic_bas < -seuil_utile4) {
  zone_decision4 <- "gain_possible"
  decision4 <- "Un gain utile reste possible mais incertain ; proposer un pilote avant généralisation."
} else {
  zone_decision4 <- "gain_non_etaye"
  decision4 <- "Le gain utile n'est pas étayé ; ne pas généraliser sur cette seule étude."
}
recommandation4 <- c(
  "Noria : décision sur le workflow B (données simulées)",
  sprintf("Source : 241 lignes, 1 doublon et 4 durées exclues ; analyse de %d tickets (%d A, %d B).",
          nrow(clean4), length(a4), length(b4)),
  sprintf("B - A = %.2f min ; IC95 [%.2f ; %.2f] ; p = %.4g.",
          comparaison4$delta_minutes, comparaison4$ic_bas, comparaison4$ic_haut, comparaison4$p_valeur),
  "Critère du protocole pédagogique : réduire la durée moyenne d'au moins 5 minutes ; négatif favorise B.",
  decision4,
  "L'incertitude de l'IC ne permet pas d'affirmer avec précision un gain de 5 minutes.",
  "Les exclusions peuvent biaiser l'effet ; vérifier leurs causes et la qualité de l'affectation.",
  "Cas fictif aléatoire : aucune garantie pour un contexte réel ou une satisfaction ordinale.",
  "Suite : pilote indépendant, mesure des durées manquantes, complexité et satisfaction, puis réévaluation.")
dir.create("results", showWarnings = FALSE)
write.csv(audit4, "results/TP04_audit.csv", row.names = FALSE)
write.csv(exclusions4, "results/TP04_exclusions.csv", row.names = FALSE)
write.csv(descriptifs4, "results/TP04_descriptifs.csv", row.names = FALSE)
write.csv(comparaison4, "results/TP04_comparaison.csv", row.names = FALSE)
pdf("results/TP04_graphiques.pdf", width = 8, height = 5)
boxplot(resolution_minutes ~ workflow, data = clean4, xlab = "Workflow",
  ylab = "Durée de résolution (minutes)", main = "Noria : durées par workflow")
hist(clean4$resolution_minutes, main = "Noria : durées observées",
  xlab = "Durée de résolution (minutes)", col = "grey85")
dev.off()
writeLines(recommandation4, "results/TP04_recommandation.txt", useBytes = TRUE)
pdf("results/TP04_recommandation.pdf", width = 8.27, height = 11.69)
par(mar = c(1, 1, 1, 1))
plot.new()
texte4 <- unlist(lapply(recommandation4, function(ligne) c(strwrap(ligne, width = 83), "")))
text(.02, .97, paste(texte4, collapse = "\n"), adj = c(0, 1), cex = .83)
dev.off()
# Conserver la version de R, le système et les paquets effectivement attachés.
session4 <- sessionInfo()
writeLines(capture.output(session4), "results/TP04_sessionInfo.txt")
source("checks/TP04.R", local = TRUE, encoding = "UTF-8")
