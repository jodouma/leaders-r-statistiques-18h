# RÉFÉRENCE FACULTATIVE — pipeline complet, hors parcours obligatoire de 18 h.
# Inclut modèle et MapReduce ; bootstrap activable via run_pipeline(bootstrap=TRUE).
# Aucun de ces volets n'est requis
# pour terminer les quatre TP du tronc commun. Ne valide pas le travail des TP.
# Depuis la racine : Rscript scripts/01_run_all.R
# Dans RStudio : source("scripts/01_run_all.R")
source("scripts/00_check_setup.R", encoding = "UTF-8")
files <- sort(list.files("R", pattern = "[.]R$", full.names = TRUE))
for (file in files) source(file, encoding = "UTF-8")
# Chaque étape peut être appelée séparément après ce chargement des fonctions.
cat("Référence facultative : exécution du pipeline complet (avec extensions).\n")
result <- run_pipeline()
print(result$audit, row.names = FALSE)
print(result$inference$result, row.names = FALSE)
