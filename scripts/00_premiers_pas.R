# Noria Gestion — premiers pas dans RStudio
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
output_dir <- prepare_output("00")


# B02 — Lire une petite expression ----
# Une expression est une instruction calculée par R ; print montre sa valeur.
# Exemple inventé : 2 parts à 150 unités monétaires (UM).
print(2 * 150)

# B03 — Nommer puis consulter une valeur ----
# <- range la valeur à droite dans le nom à gauche.
capital <- 10000
# Ce contrôle protège le paramètre modifiable ; stop rend la main avec un message.
validate_capital(capital)
currency <- "UM"
print(capital)
print(currency)
# Un nom peut être réutilisé dans un nouveau calcul.
capital_after_gain <- capital + 500
print(capital_after_gain)

# B04 — Essayer et garder une trace ----
# Expérience : changez 10000 dans B03, puis relancez B03 et B04.
summary <- data.frame(capital_UM = capital, gain_UM = 500,
                      final_capital_UM = capital_after_gain)
print(summary)
save_table(summary, output_dir, "premier_calcul.csv")
self_check(capital_after_gain == capital + 500,
           "Le capital final est le capital choisi augmenté de 500 UM.")

# Le CSV se lit automatiquement dans un onglet de tableau en RStudio.
# Pour modifier le code, revenir à l’onglet de ce script dans Source.
inspect_export(output_dir, "premier_calcul.csv")
