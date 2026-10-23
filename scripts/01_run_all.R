# Depuis la racine : Rscript scripts/01_run_all.R
# Dans RStudio : source("scripts/01_run_all.R")
source("scripts/00_check_setup.R", encoding = "UTF-8")
files <- sort(list.files("R", pattern = "[.]R$", full.names = TRUE))
for (file in files) source(file, encoding = "UTF-8")
# Chaque étape peut être appelée séparément après ce chargement des fonctions.
result <- run_pipeline()
print(result$audit, row.names = FALSE)
print(result$inference$result, row.names = FALSE)
