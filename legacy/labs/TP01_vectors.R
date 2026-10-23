# ARCHIVE FACULTATIVE — ancien parcours à six TP, hors tronc commun de 18 h.
# Exécuter depuis la racine : source("legacy/labs/TP01_vectors.R")
source("scripts/00_check_setup.R", encoding = "UTF-8")
for (file in sort(list.files("R", pattern = "[.]R$", full.names = TRUE))) {
  source(file, encoding = "UTF-8")
}
# TP01 — Prendre en main les vecteurs, les objets et les NA.
# Objectif : écrire et expliquer chaque expression sans copier une fonction fournie.
delais <- c(42, NA_real_, 35, 80, 55, NA_real_, 20, 60)
# TODO 1 : prédire length(delais), mean(delais), typeof(is.na(delais)) ; puis vérifier.
# TODO 2 : créer valeurs observées, délais observés <=55, indicateur observé et >50.
# TODO 3 : calculer NA, n observé, somme, moyenne et médiane ; expliquer na.rm.
# TODO 4 : comparer delais[1:3], delais[-1], delais[delais>50] ; corriger le masqueNA.
# TODO 5 : provoquer une erreur réversible, noter puis corriger le message.
# TODO 6 : ajouter deux stopifnot() de propriétés utiles et relancer sans objets cachés.
# Auto-contrôle après recherche : 8 valeurs,6 observées,2NA,somme292.
# Défi : fonction renvoyant effectif total,observé,moyenne ; cas vide et tout-NA.
# Objets/attributs : nommer le vecteur ; construire une liste et inspecter str()/attributes().
# Livrable : script commenté et trois phrases problème -> vérification -> résultat.
