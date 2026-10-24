# Noria Gestion — importer les marchés
# Ouvrez course.Rproj. Dans ce fichier, exécutez B01 puis les blocs suivants.
# Dans un bloc Bxx : Ctrl+Alt+T (Code > Run Region > Run Code Section).
# Les données historiques sont des niveaux d'indices, sans dates inventées.

# B01 — Préparer cette séance ----
# getwd() désigne le dossier du projet ; les chemins partent de ce dossier.
if (!file.exists("course.Rproj") || !file.exists("R/outils.R")) {
  stop("Dossier incorrect : ouvrez course.Rproj (File > Open Project), puis relancez B01.", call. = FALSE)
}
# source charge les outils fournis ; vous n'avez aucune commande à recopier.
source("R/outils.R", encoding = "UTF-8")
output_dir <- prepare_output("02")


# B02 — Importer le CSV réel enrichi ----
# Une table contient des lignes (observations) et des colonnes (variables).
# read_markets lit le fichier et vérifie ses colonnes ; aucune donnée n'est modifiée.
raw <- read_markets()
# head affiche les six premières lignes ; dim indique lignes puis colonnes.
print(head(raw))
print(dim(raw))

# B03 — Examiner une colonne et ses premières valeurs ----
# $ choisit une colonne par son nom ; [1:5] choisit les positions 1 à 5.
print(names(raw))
print(raw$CAC[1:5])
# str montre la structure : ici des colonnes numériques.
str(raw)

# B04 — Comparer la source et le fichier d'entraînement ----
original <- read_markets("data/marches_source.csv")
comparison <- data.frame(file = c("source réelle", "entraînement enrichi"),
                         rows = c(nrow(original), nrow(raw)))
print(comparison)
save_table(comparison, output_dir, "importation.csv")
# n indique combien de premières lignes afficher ; ici le fichier original.
preview_rows <- 6
print(head(original, n = preview_rows))
# Expérience : preview_rows <- 10, puis relancez B04.
self_check(all(c("DAX", "SMI", "CAC", "FTSE") %in% names(raw)),
           "Les quatre indices sont présents ; observation est un ordre, pas une date.")
cat("Source : datasets::EuStockMarkets, historique 1991–1998, 1860 observations.\n")
cat("Entraînement : un doublon exact + une ligne FTSE manquante ajoutés.\n")

# Le CSV se lit automatiquement dans un onglet de tableau en RStudio.
# Pour modifier le code, revenir à l’onglet de ce script dans Source.
inspect_export(output_dir, "importation.csv")
