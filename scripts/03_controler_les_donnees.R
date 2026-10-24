# Noria Gestion — contrôler les données
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
output_dir <- prepare_output("03")
raw <- read_markets()

# B02 — Repérer les anomalies ajoutées pour apprendre ----
# TRUE signifie vrai ; duplicated compare toutes les colonnes de chaque ligne.
repeated <- duplicated(raw)
print(sum(repeated))
print(raw[repeated, ])
# ! inverse TRUE/FALSE ; on garde les lignes qui ne répètent pas une ligne entière.
unique_data <- raw[!repeated, ]
complete <- complete.cases(unique_data)
print(sum(!complete))
print(unique_data[!complete, ])

# B03 — Séparer, sans supprimer un rendement extrême réel ----
quarantine <- unique_data[!complete, ]
prices <- unique_data[complete, ]
# order retrouve l'ordre des observations ; observation n'est pas une date.
prices <- prices[order(prices$observation), ]
# Le contrôle partagé détecte aussi les identifiants contradictoires.
validated <- clean_markets(raw)
print(head(prices))
counts <- data.frame(stage = c("brut", "sans doublon exact", "complet", "quarantaine"),
                     rows = c(nrow(raw), nrow(unique_data), nrow(prices), nrow(quarantine)))
print(counts)

# B04 — Enregistrer les deux tables et vérifier ----
save_table(prices, output_dir, "marches_propres.csv")
save_table(quarantine, output_dir, "quarantaine.csv")
save_table(counts, output_dir, "controle.csv")
self_check(nrow(prices) + nrow(quarantine) == nrow(unique_data),
           "Chaque ligne unique est soit complète, soit mise en quarantaine.")

# B05 — Essayer une valeur manquante en mémoire ----
# demo est une copie en mémoire ; le CSV original reste intact.
demo <- raw
# NA représente une information inconnue, différente de zéro.
demo_row <- 10
# Expérience : demo_row <- 20, puis relancez B05.
demo$FTSE[demo_row] <- NA
demo_cleaned <- clean_markets(demo)
print(nrow(demo_cleaned$quarantine))
# Le total peut rester identique ; la colonne observation montre quelle ligne a changé.
print(demo_cleaned$quarantine)
self_check(nrow(demo_cleaned$quarantine) >= nrow(quarantine),
           "Une valeur rendue inconnue est isolée ; les fichiers data/ restent intacts.")

# Le CSV se lit automatiquement dans un onglet de tableau en RStudio.
# Pour modifier le code, revenir à l’onglet de ce script dans Source.
inspect_export(output_dir, "controle.csv")
