# Noria Gestion — calculer les rendements
# Ouvrez course.Rproj. Dans ce fichier, exécutez B01 puis les blocs suivants.
# Run / Ctrl+Enter exécute la ligne ou la sélection ; les résultats sont en Console.
# Les données historiques sont des niveaux d'indices, sans dates inventées.

# B01 — Préparer cette séance ----
# getwd() désigne le dossier du projet ; les chemins partent de ce dossier.
if (!file.exists("course.Rproj") || !file.exists("R/outils.R")) {
  stop("Dossier incorrect : ouvrez course.Rproj (File > Open Project), puis relancez B01.", call. = FALSE)
}
# source charge les outils fournis ; vous n'avez aucune commande à recopier.
source("R/outils.R", encoding = "UTF-8")
output_dir <- prepare_output("04")
# Chaque fichier repart du CSV ; aucun objet d'une séance précédente n'est requis.
raw <- read_markets()
cleaned <- clean_markets(raw)
prices <- cleaned$prices
# Une ligne retirée au milieu créerait un intervalle de durée différente.
validate_spacing(prices)

# B02 — Comprendre une seule variation réelle ----
# [ligne, colonne] sélectionne une cellule ; $CAC sélectionne la colonne entière.
old_value <- prices$CAC[1]
new_value <- prices$CAC[2]
first_return <- (new_value - old_value) / old_value
print(data.frame(old_CAC = old_value, new_CAC = new_value,
                 return_decimal = first_return, return_percent = 100 * first_return))

# B03 — Étendre le même calcul aux observations voisines ----
# as.matrix rassemble les 4 colonnes numériques ; -1 enlève la première ligne.
levels <- as.matrix(prices[market_names])
new_levels <- levels[-1, ]
old_levels <- levels[-nrow(levels), ]
values <- new_levels / old_levels - 1
returns <- data.frame(observation = prices$observation[-1], values)
print(head(returns))
print(nrow(returns))
save_table(returns, output_dir, "rendements.csv")

# B04 — Observer et vérifier une série ----
market <- "CAC"
# Expérience : remplacez CAC par DAX ci-dessus, puis relancez B04.
save_plot(output_dir, "rendements.png", {
  plot(returns$observation, 100 * returns[[market]], type = "l", col = "#087F8C",
       xlab = "Observation (ordre)", ylab = "Rendement par observation (%)",
       main = paste("Variations historiques —", market))
  abline(h = 0, col = "gray60")
})
self_check(nrow(returns) == nrow(prices) - 1,
           "Deux niveaux voisins donnent une variation : une ligne de moins.")
