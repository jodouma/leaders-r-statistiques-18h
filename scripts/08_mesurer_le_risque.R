# Noria Gestion — mesurer le risque historique
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
output_dir <- prepare_output("08")
# Chaque fichier repart du CSV ; aucun objet d'une séance précédente n'est requis.
raw <- read_markets()
cleaned <- clean_markets(raw)
prices <- cleaned$prices
returns <- make_returns(prices)
portfolio <- basket_returns(returns)

# B02 — Transformer les variations en pertes ----
capital <- 10000
confidence <- 0.95
# Vérifier les bornes évite un calcul sans sens après une modification.
validate_capital(capital)
if (length(confidence) != 1 || !is.finite(confidence) || confidence <= 0 || confidence >= 1)
  stop("Choisissez une confiance strictement comprise entre 0 et 1.")
losses <- -portfolio
# quantile(type = 7) interpole le seuil historique ; environ 95 % des pertes sont sous ce seuil.
var_rate <- as.numeric(quantile(losses, probs = confidence, type = 7))
var_amount <- capital * var_rate
print(data.frame(confidence = confidence, VaR_percent = 100 * var_rate, VaR_UM = var_amount))
# Cette VaR par observation n'est ni une perte maximale ni une garantie future.

# B03 — Mesurer la baisse depuis un sommet déjà atteint ----
wealth <- capital * cumprod(c(1, 1 + portfolio))
# cummax garde le plus haut capital atteint jusqu'à chaque position.
peak <- cummax(wealth)
drawdown <- wealth / peak - 1
print(100 * min(drawdown))
summary <- data.frame(confidence = confidence, historical_VaR_UM = var_amount,
                      maximum_drawdown = min(drawdown), final_capital_UM = tail(wealth, 1))
print(summary)
save_table(summary, output_dir, "risque.csv")
save_table(data.frame(observation = prices$observation, drawdown = drawdown), output_dir, "drawdown.csv")

# B04 — Lire la profondeur des baisses ----
# Expérience : confidence <- 0.99 en B02 ; relancez B02 à B04 et comparez le seuil.
save_plot(output_dir, "drawdown.png", {
  plot(prices$observation, 100 * drawdown, type = "l", col = "#C24B4B",
       xlab = "Observation (ordre)", ylab = "Écart au sommet (%)", main = "Drawdown historique du panier")
  abline(h = 0, col = "gray60")
})
self_check(all(drawdown <= 1e-12) && drawdown[1] == 0,
           "Un drawdown est nul au sommet ou négatif sous le sommet.")
cat("Panier local rééquilibré. Séries d’indices utilisées telles quelles ; aucun traitement supplémentaire du change, des frais ou des dividendes. Conventions des indices potentiellement différentes.\n")

# Le CSV se lit automatiquement dans un onglet de tableau en RStudio.
# Pour modifier le code, revenir à l’onglet de ce script dans Source.
inspect_export(output_dir, "risque.csv")
