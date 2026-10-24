# Noria Gestion — tester une association (découverte guidée)
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
output_dir <- prepare_output("11")
# Chaque fichier repart du CSV ; aucun objet d'une séance précédente n'est requis.
raw <- read_markets()
cleaned <- clean_markets(raw)
prices <- cleaned$prices
returns <- make_returns(prices)

# B02 — Séparer le passé en deux parties chronologiques ----
train_fraction <- 0.80
if (length(train_fraction) != 1 || !is.finite(train_fraction) || train_fraction <= 0 || train_fraction >= 1)
  stop("Choisissez une part d’entraînement strictement comprise entre 0 et 1.")
# floor arrondit vers le bas ; les premières observations servent à ajuster le modèle.
cutoff <- floor(train_fraction * nrow(returns))
if (cutoff < 3 || cutoff >= nrow(returns)) stop("La part d'entraînement doit laisser deux groupes utilisables.")
train <- returns[seq_len(cutoff), ]
test <- returns[(cutoff + 1):nrow(returns), ]
print(c(train_rows = nrow(train), test_rows = nrow(test)))

# B03 — Ajuster, puis estimer sur la partie réservée ----
# lm ajuste une droite : CAC ~ DAX signifie expliquer CAC avec DAX de la même observation.
model <- lm(CAC ~ DAX, data = train)
print(coef(model))
# predict reçoit uniquement le DAX des lignes de test ; le modèle n'y est pas réajusté.
predicted <- predict(model, newdata = test)
baseline <- rep(mean(train$CAC), nrow(test))
# Ce modèle utilise le DAX simultané : il ne prédit pas le lendemain.

# B04 — Comparer les erreurs sur les mêmes lignes ----
# RMSE : racine de la moyenne des écarts au carré ; une valeur plus basse est préférable.
model_rmse <- sqrt(mean((test$CAC - predicted)^2))
baseline_rmse <- sqrt(mean((test$CAC - baseline)^2))
summary <- data.frame(method = c("droite CAC ~ DAX", "moyenne CAC entraînement"),
                      test_RMSE_percent = 100 * c(model_rmse, baseline_rmse))
print(summary)
save_table(summary, output_dir, "erreurs_test.csv")
save_table(data.frame(observation = test$observation, actual_CAC = test$CAC,
                      estimated_CAC = predicted, baseline = baseline), output_dir, "estimations_test.csv")

# B05 — Examiner l'association et ses limites ----
# Expérience : train_fraction <- 0.70 en B02 ; relancez B02 à B05.
save_plot(output_dir, "modele.png", {
  plot(100 * test$DAX, 100 * test$CAC, pch = 16, col = "#087F8C80",
       xlab = "Rendement DAX simultané (%)", ylab = "Rendement CAC simultané (%)",
       main = "Partie réservée : association contemporaine")
  # Les coefficients portent sur les rendements décimaux : seul l'intercept change d'échelle.
  abline(a = 100 * coef(model)[1], b = coef(model)[2], col = "#C24B4B", lwd = 2)
})
self_check(max(train$observation) < min(test$observation),
           "L'entraînement précède le test ; aucune ligne future n'a servi à ajuster.")
cat("Association contemporaine, sans causalité ni prévision du lendemain.\n")

# Le CSV se lit automatiquement dans un onglet de tableau en RStudio.
# Pour modifier le code, revenir à l’onglet de ce script dans Source.
inspect_export(output_dir, "erreurs_test.csv")
