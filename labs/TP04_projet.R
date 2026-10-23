# TP04 — Projet autonome : de la source à la décision · 150 min · R de base, depuis la racine du projet.
# 1. Ouvrez course.Rproj ; ouvrez ce fichier dans l'éditeur.
# 2. Lisez la première consigne puis exécutez une ligne avec Ctrl/Cmd + Entrée.
# 3. Remplacez les TODO ; exécutez ensuite tout le fichier de haut en bas.
# 4. Lancez source("checks/TP04.R", encoding = "UTF-8").
# Résultat final attendu du contrôle : « TP04 : contrôles réussis. »
# Un contrôle rouge nomme l'objet à corriger ; ne copiez pas le corrigé.
# Voir le PDF 13_TP04_projet.pdf pour les calculs à la main et les critères de réussite.

# Aucune dépendance à un TP exécuté : importer le CSV brut dans une session vide.
# Étape 1 : écrire un plan papier (unité, anomalies, règles, contraste et seuil utile).
# Vous pouvez recopier VOS fonctions antérieures en les lisant ; aucun source("R/...").
raw4 <- read.csv("data/noria_dirty.csv", na.strings = c("", "NA"), stringsAsFactors = FALSE,
  colClasses = c("integer", "character", "numeric", "numeric", "numeric", "character"))
# Les fonctions sont des contrats à remplir ; elles échouent clairement tant qu'elles sont vides.
nettoyer_projet <- function(brut) {
  stop("TODO nettoyer_projet : renvoyer list(data, audit, exclusions) avec les règles du TP02.")
}
decrire_projet <- function(donnees) {
  stop("TODO decrire_projet : tableau A/B, n, moyenne, ecart_type, q1, mediane, q3.")
}
# TODO : appelez vos fonctions puis affectez les objets ci-dessous.
clean4 <- data.frame()
audit4 <- data.frame()
exclusions4 <- data.frame()
descriptifs4 <- data.frame()
test4 <- NULL                 # TODO : Welch indépendant, B - A.
comparaison4 <- data.frame()   # contraste, delta_minutes, ic_bas, ic_haut, p_valeur.
# Critère du protocole pédagogique : un gain moyen >= 5 min est considéré utile.
# Le scénario ne documente pas de préenregistrement historique de ce critère.
seuil_utile4 <- 5
zone_decision4 <- "TODO"       # gain_etaye / gain_possible / gain_non_etaye.
# Si IC haut < -5 : gain_etaye. Sinon si IC bas < -5 : gain_possible.
# Sinon : gain_non_etaye. Ne confondez pas p < 0.05 et utilité opérationnelle.
recommandation4 <- c("TODO résultat chiffré", "TODO décision conditionnelle",
                     "TODO limites et prochaine action")
# TODO : écrire results/TP04_audit.csv, TP04_exclusions.csv, TP04_descriptifs.csv,
# TP04_comparaison.csv ; produire TP04_graphiques.pdf (boîte + histogramme).
# TODO : produire results/TP04_recommandation.pdf, UNE page de texte lisible,
# et results/TP04_recommandation.txt contenant recommandation4 (writeLines).
# La recommandation cite effectifs/pertes, delta/IC/p, seuil utile, incertitude et suivi.
# TODO : enregistrer aussi l'environnement d'exécution pour la reproductibilité.
session4 <- NULL             # TODO : sessionInfo().
# writeLines(capture.output(session4), "results/TP04_sessionInfo.txt")
