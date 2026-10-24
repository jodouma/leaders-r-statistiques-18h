# Noria Gestion — composer un panier pédagogique
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
output_dir <- prepare_output("07")
# Chaque fichier repart du CSV ; aucun objet d'une séance précédente n'est requis.
raw <- read_markets()
cleaned <- clean_markets(raw)
prices <- cleaned$prices
returns <- make_returns(prices)

# B02 — Choisir les poids et calculer le panier ----
cac_weight <- 0.60
dax_weight <- 1 - cac_weight
capital <- 10000
validate_capital(capital)
# Les poids sont rééquilibrés à chaque observation ; ceci n'est pas un produit tradable.
# Le contrôle du poids donne un message lisible si la valeur sort de [0, 1].
checked_portfolio <- basket_returns(returns, cac_weight)
portfolio <- cac_weight * returns$CAC + dax_weight * returns$DAX
print(head(portfolio))
print(c(CAC = cac_weight, DAX = dax_weight))

# B03 — Composer le capital au fil des observations ----
# cumprod multiplie successivement les facteurs 1 + rendement.
# c(1, ...) ajoute le point de départ avant la première variation.
wealth <- capital * cumprod(c(1, 1 + portfolio))
path <- data.frame(observation = prices$observation, capital_UM = wealth)
print(tail(path))
save_table(path, output_dir, "capital_panier.csv")
save_table(data.frame(observation = returns$observation, portfolio_return = portfolio),
           output_dir, "rendements_panier.csv")

# B04 — Visualiser puis modifier une hypothèse ----
# Expérience : cac_weight <- 0.80 en B02, puis relancez B02 à B04.
save_plot(output_dir, "capital_panier.png", {
  plot(path$observation, path$capital_UM, type = "l", col = "#087F8C",
       xlab = "Observation (ordre)", ylab = "Capital pédagogique (UM)",
       main = "Panier rééquilibré à chaque observation")
})
self_check(abs(cac_weight + dax_weight - 1) < 1e-12 && wealth[1] == capital,
           "Les poids totalisent 100 % et le chemin inclut le capital initial.")
cat("Séries d’indices utilisées telles quelles ; aucun traitement supplémentaire du change, des frais ou des dividendes. Conventions des indices potentiellement différentes. Historique ancien, sans conseil d'investissement.\n")
