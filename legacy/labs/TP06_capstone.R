# ARCHIVE FACULTATIVE — ancien parcours à six TP, hors tronc commun de 18 h.
# Exécuter depuis la racine : source("legacy/labs/TP06_capstone.R")
source("scripts/00_check_setup.R", encoding = "UTF-8")
for (file in sort(list.files("R", pattern = "[.]R$", full.names = TRUE))) {
  source(file, encoding = "UTF-8")
}
# TP06 — Mission autonome Noria : recommandation reproductible.
# Réaliser un script complet ; les fonctions de référence restent une aide facultative.
# Source : data/noria_dirty.csv ; une ligne représente un ticket indépendant.
# TODO 1 : définir question, variable cible, unité et règles d'exclusion AVANT le test.
# TODO 2 : importer sans modifier le fichier, auditer les anomalies, nettoyer.
# TODO 3 : vérifier les identifiants et facteurs ; décrire les deux groupes.
# TODO 4 : comparer B-A avec IC95 % de Welch et expliquer les limites.
# TODO 5 : ajuster lm(resolution_minutes ~ workflow + complexity + team).
# TODO 6 : inspecter les résidus et comparer estimation brute/ajustée.
# TODO 7 : exporter tableaux, graphiquesPDF et sessionInfo dans results/capstone/.
# TODO 8 : formuler une conclusion : taille de l'effet, incertitude, action suivante.
# Défi après noyau : démontrer une réduction sum/count sur des partitions inégales.
# Critères : 236 tickets ; 12 notes manquantes ; contraste signé ; audit traçable ;
# script relançable depuis la racine ; aucune conclusion réelle tirée d'une simulation.
