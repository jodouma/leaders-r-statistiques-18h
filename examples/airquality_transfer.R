# BONUS FACULTATIF — Transférer la démarche à de vraies mesures historiques.
# Exécuter depuis la racine du cours :
# source("examples/airquality_transfer.R", encoding = "UTF-8")
# Données fournies avec R, sans téléchargement ni paquet supplémentaire.
# Consulter ?datasets::airquality pour les sources, unités et limites.
source("scripts/00_check_setup.R", encoding = "UTF-8")

# Une ligne = un jour à New York, de mai à septembre 1973.
# Ozone est en ppb ; Temp est le maximum journalier en degrés Fahrenheit.
raw <- datasets::airquality
dir.create("results/airquality", recursive = TRUE, showWarnings = FALSE)

# La question porte sur Ozone et Temp seulement : ne pas supprimer une ligne
# parce que Solar.R manque si cette variable n'entre pas dans notre analyse.
keep <- complete.cases(raw[c("Ozone", "Temp")])
d <- raw[keep, , drop = FALSE]
d$temp_c <- (d$Temp - 32) * 5 / 9
audit <- data.frame(raw_days = nrow(raw), analysed_days = nrow(d),
                    missing_ozone = sum(is.na(raw$Ozone)),
                    excluded_days = sum(!keep))
stopifnot(nrow(raw) == 153L, nrow(d) == 116L)
write.csv(audit, "results/airquality/audit.csv", row.names = FALSE)

# Le modèle décrit une association historique, pas un effet causal.
# Les jours successifs peuvent être dépendants et la saison confondre le lien.
# Ne pas interpréter une p-valeur/IC classique comme preuve causale.
model <- lm(Ozone ~ temp_c, data = d)
write.csv(data.frame(term = names(coef(model)), estimate = unname(coef(model))),
          "results/airquality/coefficients.csv", row.names = FALSE)
pdf("results/airquality/association.pdf", width = 8, height = 5)
plot(d$temp_c, d$Ozone, pch = 19, col = "#087D7788",
     xlab = "Temperature maximale (degres C)", ylab = "Ozone (ppb)",
     main = "New York, mai-septembre 1973 : association observee")
abline(model, col = "#D4603D", lwd = 2)
dev.off()
capture.output(sessionInfo(), file = "results/airquality/sessionInfo.txt")
print(audit)
print(coef(model))
message("Bonus termine : resultats dans results/airquality")
# Travail : comparer la suppression Ozone/Temp (116 jours) a complete.cases(raw)
# (111 jours), puis expliquer pourquoi ce changement de population compte.
