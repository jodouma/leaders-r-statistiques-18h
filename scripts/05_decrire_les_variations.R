# Noria Gestion — décrire les variations
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
output_dir <- prepare_output("05")
# Chaque fichier repart du CSV ; aucun objet d'une séance précédente n'est requis.
raw <- read_markets()
cleaned <- clean_markets(raw)
prices <- cleaned$prices
returns <- make_returns(prices)

# B02 — Décrire une colonne ----
market <- "CAC"
series <- returns[[market]]
# mean = moyenne, median = milieu, sd = dispersion autour de la moyenne.
print(mean(series))
print(median(series))
print(sd(series))
print(range(series))

# B03 — Mettre les statistiques dans une table ----
summary <- data.frame(market = market, observations = length(series),
                      mean_percent = 100 * mean(series), median_percent = 100 * median(series),
                      sd_percent = 100 * sd(series), min_percent = 100 * min(series),
                      max_percent = 100 * max(series))
print(summary)
save_table(summary, output_dir, "statistiques.csv")
# La moyenne par observation n'est pas le rendement composé de toute la période.

# B04 — Voir la répartition et expérimenter ----
# hist regroupe les valeurs en intervalles ; breaks propose un nombre de classes.
bins <- 30
# Expérience : bins <- 15, puis relancez B04 ; les données restent les mêmes.
save_plot(output_dir, "distribution.png", {
  hist(100 * series, breaks = bins, col = "#087F8C", border = "white",
       xlab = "Rendement par observation (%)", ylab = "Nombre d'observations",
       main = paste("Répartition historique —", market))
})
self_check(min(series) <= median(series) && median(series) <= max(series),
           "La médiane se trouve entre le minimum et le maximum.")

# Le CSV se lit automatiquement dans un onglet de tableau en RStudio.
# Pour modifier le code, revenir à l’onglet de ce script dans Source.
inspect_export(output_dir, "statistiques.csv")
