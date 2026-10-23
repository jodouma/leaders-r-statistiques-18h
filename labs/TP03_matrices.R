# Exécuter depuis la racine : source("labs/TP03_matrices.R")
source("scripts/00_check_setup.R", encoding = "UTF-8")
for (file in sort(list.files("R", pattern = "[.]R$", full.names = TRUE))) {
  source(file, encoding = "UTF-8")
}
# TP03 — Dimensions, fonctions, conditions, boucles.
values <- 1:12
# TODO 1 : former deux matrices 3 x 4, par colonnes puis avec byrow = TRUE.
# TODO 2 : nommer lignes/colonnes ; extraire case, ligne, colonne, bloc2x2 ; comparer drop = FALSE.
# TODO 3 : calculer les sommes de lignes avec for, puis apply(..., 1, sum), puis les colonnes.
# TODO 4 : écrire une fonction de moyenne sûre : numérique, NA, tout-NA, Inf.
# TODO 5 : la tester sur c(2, NA, 4), numeric(0), c(NA_real_, NA_real_), "10".
# TODO 6 : expliquer as.matrix(data.frame(nombre = 1:2, groupe = c("A", "B"))).
# Reprise TP02 si nécessaire : d <- clean_noria(read_noria())$data
# TODO 7 : table(d$complexity, d$workflow), rowSums(), colSums(), sum() ; total236.
# Défi : remplacer seulement les valeurs négatives d'une matrice sans changer dim().
# Livrable : fonction commentée et explication du piège apply sur un tableau mixte.
