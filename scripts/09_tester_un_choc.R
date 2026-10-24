# Noria Gestion — tester un choc inventé
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
output_dir <- prepare_output("09")
# Chaque fichier repart du CSV ; aucun objet d'une séance précédente n'est requis.
raw <- read_markets()
cleaned <- clean_markets(raw)
prices <- cleaned$prices
returns <- make_returns(prices)

# B02 — Poser le scénario inventé, distinct de l'historique ----
capital <- 10000
cac_weight <- 0.60
dax_weight <- 1 - cac_weight
cac_shock <- -0.02
dax_shock <- -0.12
# Les contrôles bornent les hypothèses économiques modifiables.
validate_capital(capital)
if (length(cac_weight) != 1 || !is.finite(cac_weight) || cac_weight < 0 || cac_weight > 1)
  stop("Le poids CAC doit être compris entre 0 et 1.")
if (length(cac_shock) != 1 || length(dax_shock) != 1 ||
    !all(is.finite(c(cac_shock, dax_shock))) || min(c(cac_shock, dax_shock)) < -1)
  stop("Chaque choc doit être un taux fini au moins égal à -1.")
# Ce choc simultané est une hypothèse pédagogique, pas une prévision.
scenario_return <- cac_weight * cac_shock + dax_weight * dax_shock
final_capital <- capital * (1 + scenario_return)
print(100 * scenario_return)
print(final_capital)
# La perte en UM est le capital initial moins le capital après le choc.
print(c(perte_UM = capital - final_capital))

# B03 — Décomposer la perte du panier ----
contributions <- data.frame(market = c("CAC", "DAX"),
                            weight = c(cac_weight, dax_weight),
                            shock = c(cac_shock, dax_shock))
contributions$contribution <- contributions$weight * contributions$shock
print(contributions)
save_table(contributions, output_dir, "contributions_choc.csv")
summary <- data.frame(initial_capital_UM = capital, scenario_return = scenario_return,
                      final_capital_UM = final_capital)
save_table(summary, output_dir, "choc.csv")

# B04 — Comparer les contributions et expérimenter ----
# Expérience : dax_shock <- -0.20 en B02 ; relancez B02 à B04.
save_plot(output_dir, "choc.png", {
  barplot(100 * contributions$contribution, names.arg = contributions$market,
          col = c("#087F8C", "#C24B4B"), ylab = "Contribution au rendement (points de %)",
          main = "Choc inventé : contribution de chaque indice")
  abline(h = 0)
})
self_check(abs(sum(contributions$contribution) - scenario_return) < 1e-12,
           "La somme des contributions retrouve le rendement du scénario.")
cat("UM pédagogiques, sans conseil d'investissement. Séries d’indices utilisées telles quelles ; aucun traitement supplémentaire du change, des frais ou des dividendes. Conventions des indices potentiellement différentes.\n")
