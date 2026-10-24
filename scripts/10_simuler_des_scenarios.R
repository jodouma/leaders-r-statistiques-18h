# Noria Gestion — simuler des scénarios (option)
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
output_dir <- prepare_output("10")
# Chaque fichier repart du CSV ; aucun objet d'une séance précédente n'est requis.
raw <- read_markets()
cleaned <- clean_markets(raw)
prices <- cleaned$prices
returns <- make_returns(prices)
portfolio <- basket_returns(returns)

# B02 — Fixer les hypothèses de simulation ----
capital <- 10000
horizon <- 20
paths <- 5000
seed <- 2026
# Horizon et nombre de chemins sont des comptes entiers strictement positifs.
validate_capital(capital)
if (length(horizon) != 1 || length(paths) != 1 ||
    !all(is.finite(c(horizon, paths))) || min(c(horizon, paths)) < 1 ||
    any(c(horizon, paths) != floor(c(horizon, paths))))
  stop("Horizon et nombre de scénarios doivent être des entiers positifs.")
if (length(seed) != 1 || !is.finite(seed) || seed < 0 || seed > .Machine$integer.max || seed != floor(seed))
  stop("La graine doit être un entier entre 0 et la limite entière de R.")
# La graine rend ce tirage reproductible, si les données et paramètres sont identiques.
set.seed(seed)
# Tirer avec remise : la même variation historique peut revenir plusieurs fois.
# Hypothèse iid : observations indépendantes et même distribution, hypothèse simplificatrice.
sampled <- sample(portfolio, size = horizon * paths, replace = TRUE)
# matrix range les tirages dans un tableau : une colonne = un scénario.
scenarios <- matrix(sampled, nrow = horizon, ncol = paths)

# B03 — Composer chaque scénario et lire des quantiles ----
# apply(..., 2, prod) multiplie les facteurs dans chaque colonne.
final_capitals <- capital * apply(1 + scenarios, 2, prod)
probabilities <- c(0.05, 0.50, 0.95)
summary <- data.frame(probability = probabilities,
                      final_capital_UM = as.numeric(quantile(final_capitals, probabilities, type = 7)))
print(summary)
save_table(summary, output_dir, "quantiles_simules.csv")
save_table(data.frame(scenario = seq_len(paths), final_capital_UM = final_capitals),
           output_dir, "scenarios.csv")

# B04 — Lire la dispersion puis changer l'horizon ----
# Expérience : horizon <- 40 en B02 ; relancez B02 à B04.
save_plot(output_dir, "simulation.png", {
  hist(final_capitals, breaks = 40, col = "#087F8C", border = "white",
       xlab = "Capital final simulé (UM)", ylab = "Nombre de scénarios",
       main = paste(paths, "scénarios —", horizon, "observations"))
  abline(v = capital, col = "#C24B4B", lwd = 2)
})
self_check(length(final_capitals) == paths && all(is.finite(final_capitals)),
           "Un capital final fini est calculé pour chaque scénario.")
cat("Rééchantillonnage de l'historique ancien ; aucun scénario n'est une garantie future.\n")
cat("Panier local rééquilibré. Séries d’indices utilisées telles quelles ; aucun traitement supplémentaire du change, des frais ou des dividendes. Conventions des indices potentiellement différentes.\n")
