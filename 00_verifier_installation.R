# Verification non notee. Ouvrir ce dossier comme projet ou dossier de travail.
cat("R detecte :", as.character(getRversion()), "\n")
if (getRversion() < "4.1") stop("R 4.1 ou plus recent est necessaire.")
if (!file.exists("data/orders_mini.csv")) {
  stop("Ouvrez le dossier racine du cours : data/orders_mini.csv doit etre visible.")
}
# Verifier que la copie du cours est complete avant de commencer.
stems <- c("01_panier", "02_semaine", "03_importer", "04_nettoyer",
           "05_analyser", "06_visualiser", "07_decider", "08_automatiser")
attendus <- c(file.path("missions", paste0(stems, ".R")),
              file.path("solutions", paste0(stems, "_solution.R")),
              file.path("examples", paste0(stems, "_exemple.R")),
              file.path("checks", paste0(stems, ".R")),
              "checks/check_tools.R", "data/orders_mini.csv",
              "data/orders_raw.csv", "data/orders_clean_reference.csv",
              "data/orders_week2_raw.csv")
absents <- attendus[!file.exists(attendus)]
if (length(absents)) stop("Copie incomplete du cours. Fichiers absents : ",
                          paste(absents, collapse = ", "))
mini <- read.csv("data/orders_mini.csv", stringsAsFactors = FALSE)
if (nrow(mini) != 3 || !all(c("produit", "quantite") %in% names(mini))) {
  stop("Le fichier mini n'a pas les trois lignes attendues.")
}
dir.create("outputs", showWarnings = FALSE)
fichier_test <- tempfile("noria-", tmpdir = "outputs", fileext = ".png")
tryCatch({
  png(fichier_test, width = 600, height = 400)
  barplot(c(1, 2), names.arg = c("A", "B"), ylab = "Test")
  dev.off()
}, error = function(e) stop("Impossible de produire un PNG : ", conditionMessage(e)))
unlink(fichier_test)
cat("OK : lecture CSV, dossier outputs et image PNG. Aucun package a installer.\n")
cat("Verification non notee : commencez missions/01_panier.R.\n")
