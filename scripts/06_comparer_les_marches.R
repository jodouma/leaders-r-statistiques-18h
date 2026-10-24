# Noria Gestion — comparer les marchés
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
output_dir <- prepare_output("06")
# Chaque fichier repart du CSV ; aucun objet d'une séance précédente n'est requis.
raw <- read_markets()
cleaned <- clean_markets(raw)
prices <- cleaned$prices
returns <- make_returns(prices)

# B02 — Partir de la même base 100 ----
# sweep divise chaque colonne par son premier niveau, puis on multiplie par 100.
# Des niveaux bruts d'indices différents ne se comparent pas comme des prix en UM.
levels <- as.matrix(prices[market_names])
normalized <- 100 * sweep(levels, 2, levels[1, ], FUN = "/")
comparison <- data.frame(observation = prices$observation, normalized)
print(head(comparison))
save_table(comparison, output_dir, "indices_base100.csv")

# B03 — Tracer une comparaison normalisée ----
selected <- c("CAC", "DAX", "SMI", "FTSE")
colors <- c("#087F8C", "#D9822B", "#555A8C", "#749043")
# Expérience : selected <- c("CAC", "DAX"), puis relancez B03.
save_plot(output_dir, "comparaison.png", {
  matplot(prices$observation, normalized[, selected, drop = FALSE], type = "l", lty = 1,
          col = colors[seq_along(selected)], xlab = "Observation (ordre)",
          ylab = "Indice normalisé (départ = 100)", main = "Comparer les trajectoires historiques")
  legend("topleft", legend = selected, col = colors[seq_along(selected)], lty = 1, bty = "n")
})

# B04 — Mesurer une association ----
# cor compare les variations simultanées ; une corrélation ne prouve aucune cause.
correlations <- cor(returns[market_names])
print(round(correlations, 3))
save_table(data.frame(market = rownames(correlations), correlations), output_dir, "correlations.csv")
self_check(all(abs(normalized[1, ] - 100) < 1e-10),
           "Chaque courbe commence à 100, quelle que soit sa devise d'origine.")
cat("Séries d’indices utilisées telles quelles ; aucun traitement supplémentaire du change, des frais ou des dividendes. Conventions des indices potentiellement différentes.\n")

# Le CSV se lit automatiquement dans un onglet de tableau en RStudio.
# Pour modifier le code, revenir à l’onglet de ce script dans Source.
inspect_export(output_dir, "indices_base100.csv")
