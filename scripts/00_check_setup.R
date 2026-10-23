# Contrôle technique seulement : Rscript scripts/00_check_setup.R
# Dans RStudio : source("scripts/00_check_setup.R") depuis course.Rproj.
if (getRversion() < "4.1.0") stop("R 4.1.0 ou plus récent est requis.")
if (!file.exists("course.Rproj")) stop("Ouvrir course.Rproj et lancer depuis sa racine.")
required <- c("data/noria_dirty.csv", "data/noria_clean_reprise.csv",
              "labs/TP01_demarrer.R", "checks/TP01.R")
if (!all(file.exists(required))) {
  stop(paste("Fichiers manquants :", paste(required[!file.exists(required)], collapse = ", ")))
}
# Aucun install.packages() : R et ses paquets fournis suffisent.
cat("Configuration technique prête. R", as.character(getRversion()), "\n")
cat("Ce succès ne valide aucun TP : il vérifie seulement le dossier et R.\n")
cat("Étape suivante : ouvrir pdf/00_premiers_pas.pdf, puis labs/TP01_demarrer.R.\n")
cat("Exécuter les lignes du TP, compléter les TODO, puis lancer son contrôle TP01.\n")
invisible(TRUE)
