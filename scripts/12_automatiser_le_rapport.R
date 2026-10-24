# Noria Gestion — automatiser un rapport local (découverte guidée)
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
output_dir <- prepare_output("12")
# Chaque fichier repart du CSV ; aucun objet d'une séance précédente n'est requis.
raw <- read_markets()
cleaned <- clean_markets(raw)
prices <- cleaned$prices

# B02 — Définir une tâche réutilisable ----
# function prépare une recette ; ses arguments sont les valeurs qu'on pourra changer.
# Tout reste local : le HTML créé n'est ni envoyé ni publié.
analyze_basket <- function(csv_path, cac_weight, capital) {
  # Chaque appel relit le CSV choisi : aucune dépendance à un ancien objet Console.
  input <- read_markets(csv_path)
  clean <- clean_markets(input)
  changes <- make_returns(clean$prices)
  portfolio <- basket_returns(changes, cac_weight)
  risk <- risk_summary(portfolio, capital, confidence = 0.95)
  data.frame(CAC_weight = cac_weight, DAX_weight = 1 - cac_weight,
             initial_capital_UM = capital, input_rows = nrow(input),
             duplicate_rows = nrow(clean$duplicates), quarantine_rows = nrow(clean$quarantine),
             complete_rows = nrow(clean$prices), observations = nrow(changes), risk)
}

# B03 — Appeler la recette pour plusieurs poids ----
input_csv <- "data/marches_brut.csv"
capital <- 10000
weights <- c(0.40, 0.60, 0.80)
# lapply appelle la recette une fois par poids ; do.call/rbind empile ses petites tables.
results <- lapply(weights, function(weight) analyze_basket(input_csv, weight, capital))
summary <- do.call(rbind, results)
print(summary)
save_table(summary, output_dir, "comparaison_paniers.csv")
# Expérience : weights <- c(0.20, 0.60, 1.00), puis relancez B03 à B05.
# Pour un autre CSV, gardez les mêmes colonnes ; changez input_csv vers une COPIE dans outputs/.

# B04 — Dessiner la comparaison et fabriquer le HTML ----
save_plot(output_dir, "comparaison_paniers.png", {
  barplot(summary$historical_VaR_UM, names.arg = paste0(100 * summary$CAC_weight, "% CAC"),
          col = "#087F8C", ylab = "VaR historique 95 % (UM par observation)",
          main = "Comparer les paniers pédagogiques")
})
# sprintf insère des nombres formatés dans une ligne ; paste0 assemble du texte.
rows <- sprintf("<tr><td>%.0f %%</td><td>%.0f %%</td><td>%.2f</td><td>%.2f %%</td><td>%.2f</td></tr>",
                100 * summary$CAC_weight, 100 * summary$DAX_weight,
                summary$historical_VaR_UM, 100 * summary$maximum_drawdown, summary$final_capital_UM)
html <- c('<!doctype html><html lang="fr"><meta charset="utf-8">',
          '<title>Noria Gestion — Rapport pédagogique</title>',
          '<style>body{font:18px system-ui;max-width:1000px;margin:40px auto;padding:20px;color:#173943}table{border-collapse:collapse;width:100%}td,th{padding:12px;border-bottom:1px solid #ccd}img{max-width:100%}</style>',
          '<h1>Noria Gestion</h1><p>Rapport pédagogique local.</p>',
          paste0('<p>Variations disponibles : ', summary$observations[1], '. Capital initial : ', capital, ' UM.</p>'),
          paste0('<p>Contrôle de l’entrée : ', summary$input_rows[1], ' lignes brutes ; ',
                 summary$duplicate_rows[1], ' doublon(s) exact(s) ; ', summary$quarantine_rows[1],
                 ' ligne(s) en quarantaine ; ', summary$complete_rows[1], ' observations complètes.</p>'),
          '<table><tr><th>CAC</th><th>DAX</th><th>VaR 95 % (UM)</th><th>Drawdown maximal</th><th>Capital final (UM)</th></tr>',
          rows, '</table><p>VaR historique par observation, quantile type 7 : ni perte maximale, ni garantie future.</p>',
          '<img src="comparaison_paniers.png" alt="VaR historique de chaque panier">',
          '<p>Source fournie pour le cours : datasets::EuStockMarkets (R), historique 1991–1998. Un autre CSV doit être documenté par son auteur. Observation = ordre, sans dates inventées. Niveaux d’indices, pas des produits tradables.</p>',
          '<p>Panier pondéré rééquilibré à chaque observation. Séries d’indices utilisées telles quelles ; aucun traitement supplémentaire du change, des frais ou des dividendes. Conventions des indices potentiellement différentes. UM pédagogiques, sans conseil d’investissement.</p>',
          '</html>')
report_path <- file.path(output_dir, "rapport_noria.html")
writeLines(enc2utf8(html), report_path, useBytes = TRUE)

# B05 — Retrouver et relire le livrable ----
cat("Rapport enregistré :", report_path, "\n")
# En RStudio, le navigateur local ouvre le fichier ; en batch, seul le chemin est affiché.

# Le CSV se lit automatiquement dans un onglet de tableau en RStudio.
# Pour modifier le code, revenir à l’onglet de ce script dans Source.
inspect_export(output_dir, "comparaison_paniers.csv")
if (interactive()) browseURL(normalizePath(report_path, winslash = "/"))
self_check(nrow(summary) == length(weights) && file.exists(report_path),
           "Une ligne par poids choisi et un rapport HTML local sont disponibles.")
