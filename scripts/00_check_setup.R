# Depuis la racine : Rscript scripts/00_check_setup.R
# Dans RStudio : source("scripts/00_check_setup.R")
if (getRversion() < "4.1.0") stop("R 4.1.0 ou plus récent est requis.")
if (!file.exists("course.Rproj")) stop("Lancer depuis le dossier contenant course.Rproj.")
required <- c("data/noria_dirty.csv", "data/noria_reference.csv", "R/00_utils.R", "R/09_pipeline.R")
if (!all(file.exists(required))) stop("Des fichiers du projet manquent.")
# Aucun install.packages() : toutes les fonctions appartiennent à R de base.
cat("Installation prête. R", as.character(getRversion()), "\n")
cat('Prochaine commande : source("scripts/01_run_all.R")\n')
invisible(TRUE)
