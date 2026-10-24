# Noria Gestion — capital et pourcentages
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
output_dir <- prepare_output("01")


# B02 — Décrire le petit scénario inventé ----
# 5 % signifie 5 pour 100 ; en R, on écrit le taux décimal 0.05.
capital <- 10000
rate <- 0.05
# Un paramètre invalide donne un message, sans fermer RStudio.
validate_capital(capital)
validate_rate(rate)
print(rate * 100)

# B03 — Calculer le gain puis le capital final ----
gain <- capital * rate
final_capital <- capital + gain
print(gain)
print(final_capital)
# Un rendement compare la variation au niveau de départ : 100 à 102 donne 2 %.
old_value <- 100
new_value <- 102
simple_return <- (new_value - old_value) / old_value
print(simple_return)
print(simple_return * 100)

# B04 — Composer deux périodes ----
# +5 %, puis -5 % : chaque taux s'applique au nouveau capital.
second_rate <- -0.05
compounded_capital <- capital * (1 + rate) * (1 + second_rate)
print(compounded_capital)
# Additionner +5 % et -5 % ne décrit pas cette composition.
summary <- data.frame(capital_UM = capital, first_rate = rate,
                      gain_UM = gain, first_final_UM = final_capital,
                      compounded_final_UM = compounded_capital)
save_table(summary, output_dir, "capital.csv")
# Expérience : rate <- 0.10 en B02 ; relancez B02 à B04.
self_check(abs(gain / capital - rate) < 1e-12,
           "Le gain divisé par le capital retrouve le taux choisi.")

# Le CSV se lit automatiquement dans un onglet de tableau en RStudio.
# Pour modifier le code, revenir à l’onglet de ce script dans Source.
inspect_export(output_dir, "capital.csv")
