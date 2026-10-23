# FIGURE DE SYNTHESE — Faire apparaître l'incertitude, pas seulement la p-valeur.
# Référence consultable après une première tentative du TP04.
source("scripts/00_check_setup.R", encoding = "UTF-8")
for (file in sort(list.files("R", pattern = "[.]R$", full.names = TRUE))) {
  source(file, encoding = "UTF-8")
}
d <- clean_noria(read_noria())$data
raw <- compare_workflows(d)$result
adjusted <- fit_noria(d)$coefficients
adjusted <- adjusted[adjusted$term == "workflowB", , drop = FALSE]
estimate <- c(raw$estimate_minutes, adjusted$estimate)
lower <- c(raw$conf_low, adjusted$conf_low)
upper <- c(raw$conf_high, adjusted$conf_high)

pdf("results/comparaison_intervalles.pdf", width = 9, height = 4.5)
par(mar = c(5, 8, 4, 2), family = "sans")
plot(NA, xlim = c(-11, 2), ylim = c(0.5, 2.5), yaxt = "n",
     xlab = "Difference B - A (minutes) : negatif = delai plus faible avec B",
     ylab = "", main = "Deux estimations prevues, deux questions")
axis(2, at = c(2, 1), labels = c("Welch : brut", "lm : ajuste"), las = 1)
abline(v = 0, col = "#193448", lty = 2)
abline(v = -5, col = "#D4603D", lty = 3)
segments(lower, c(2, 1), upper, c(2, 1), col = "#087D77", lwd = 3)
points(estimate, c(2, 1), pch = 19, col = "#087D77", cex = 1.4)
legend("topright", c("0 : aucune difference", "-5 : seuil pedagogique"),
       col = c("#193448", "#D4603D"), lty = c(2, 3), bty = "n", cex = 0.8)
dev.off()
# Les deux IC traversent -5 : aucun n'établit un gain d'au moins5min.
# Le modèle secondaire ajusté inclut complexité+équipe, prétraitement ;
# il n'est pas choisi parce que sa p-valeur est plus petite.
