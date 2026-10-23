# ARCHIVE FACULTATIVE — ancien parcours à six TP, hors tronc commun de 18 h.
# Exécuter depuis la racine : source("legacy/solutions/TP04_inference_solution.R")
source("scripts/00_check_setup.R", encoding = "UTF-8")
for (file in sort(list.files("R", pattern = "[.]R$", full.names = TRUE))) {
  source(file, encoding = "UTF-8")
}
# Corrigé TP04 — Construire puis interpréter B-A.
d <- clean_noria(read_noria())$data
a <- d$resolution_minutes[d$workflow == "A"]
b <- d$resolution_minutes[d$workflow == "B"]
welch <- t.test(x = b, y = a, var.equal = FALSE)
print(class(welch))                         # "htest"
print(names(welch))                         # statistic, parameter, p.value, conf.int, estimate, ...
print(attributes(welch))
str(welch, max.level = 1)
print(welch$estimate)                        # moyennes B puis A, et non la différence
print(welch$statistic)                       # t=-1.9623917323
print(welch$parameter)                       # df=233.7714479149
print(mean(b) - mean(a))                    # -4.5647848883 minutes
print(welch$conf.int)                        # IC95% [-9.1476483068 ; 0.0180785301]
print(welch$p.value)                         # 0.05090316485
print(compare_workflows(d)$result, row.names = FALSE)
reverse <- t.test(x = a, y = b, var.equal = FALSE)
stopifnot(isTRUE(all.equal(welch$p.value, reverse$p.value)),
          isTRUE(all.equal(as.numeric(welch$conf.int), -rev(as.numeric(reverse$conf.int)))))
# Le signe négatif indique une durée moyenne plus faible dans B.
# L'IC quantifie l'incertitude de l'écart moyen sous les hypothèses du test.
# Ici p est proche de 0.05 et l'IC inclut zéro : ne pas conclure à une égalité prouvée.
# Une p-valeur n'est ni P(H0 vraie), ni une mesure de l'intérêt opérationnel.
# L'étude est simulée ; exclusions et structure des tickets limitent toute généralisation.
# Extension facultative, explicitement distincte de l'analyse principale :
# print(bootstrap_difference(d, reps = 2000, seed = 742))

# Noyau modèle : formule additive annoncée AVANT de comparer les résultats.
d$workflow <- factor(d$workflow, levels = c("A", "B"))
d$team <- factor(d$team, levels = c("Atlas", "Boreal", "Cedre"))
modele <- lm(resolution_minutes ~ workflow + complexity + team, data = d)
print(class(modele))                         # "lm"
print(names(modele))
print(attributes(modele))
print(methods(class = "lm"))
print(coef(modele)["workflowB"])             # -5.1497687759
print(confint(modele)["workflowB", ])        # [-8.4179115974 ; -1.8816259543]
# Extraire les propriétés de l'objet, sans recopier la console à la main.
model_result <- data.frame(contrast = "B - A, ajuste", estimate_minutes = coef(modele)["workflowB"],
                           conf_low = confint(modele)["workflowB", 1],
                           conf_high = confint(modele)["workflowB", 2], row.names = NULL)
print(model_result, row.names = FALSE)
dir.create("results", showWarnings = FALSE)
pdf("results/TP04_residuals.pdf", width = 8, height = 4)
par(mfrow = c(1, 2))
plot(fitted(modele), residuals(modele), xlab = "Valeur ajustee (min)", ylab = "Residu (min)")
abline(h = 0, lty = 2)
qqnorm(residuals(modele), main = "QQ-plot des residus")
qqline(residuals(modele))
dev.off()
# Le coefficient conditionnel ne coïncide pas nécessairement avec la différence brute.
# L'ajustement sur la complexité diminue ici la dispersion résiduelle ; ce constat
# ne justifie pas de sélectionner le modèle qui donne le plus petit p.
# Examiner motifs et points influents ; un graphique ne démontre pas l'indépendance.
