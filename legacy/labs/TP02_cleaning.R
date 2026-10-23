# ARCHIVE FACULTATIVE — ancien parcours à six TP, hors tronc commun de 18 h.
# Exécuter depuis la racine : source("legacy/labs/TP02_cleaning.R")
source("scripts/00_check_setup.R", encoding = "UTF-8")
for (file in sort(list.files("R", pattern = "[.]R$", full.names = TRUE))) {
  source(file, encoding = "UTF-8")
}
# TP02 — Auditer puis nettoyer, avant de faire un graphique.
raw <- read_noria()
# TODO 1 : dimensions, str(), table(workflow, useNA = "ifany"), résumé des durées.
# TODO 2 : compter les cellules workflow/team avec espaces ; compter les doublons.
# TODO 3 : décrire une règle pour chaque anomalie ; conserver une copie de raw.
# TODO 4 : nettoyer dans l'ordre trimws -> doublons -> durées invalides -> facteurs.
# TODO 5 : produire audit et exclusions ; vérifier 241 -> 240 -> 236 lignes.
# TODO 6 : boxplot par workflow, histogramme, médiane et dispersion par groupe.
# Défi : quelles pertes risquent de compromettre l'assignation aléatoire ?
# Livrable : audit de sept métriques et graphique lisible avec unité.
