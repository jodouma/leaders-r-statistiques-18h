# TP03 — Corrigé commenté : comparer · durée indicative : 120 min · R de base, depuis la racine du projet.
# 1. Ouvrez course.Rproj ; ouvrez ce fichier dans l'éditeur.
# 2. Exécutez une ligne à la fois pour relier le calcul à sa justification.
# 3. Relancez ensuite le corrigé entier dans une session R neuve.
# 4. Lancez source("checks/TP03.R", encoding = "UTF-8").
# Résultat final attendu du contrôle : « TP03 : contrôles réussis. »
# Les contrôles en fin de script vérifient les objets et les fichiers produits.
# Voir le PDF 12_TP03_comparer.pdf pour les calculs à la main et les critères de réussite.

# Priorité à VOTRE nettoyage. Le CSV de reprise permet de poursuivre en cas de blocage.
chemin_clean <- "results/TP02_clean.csv"
mode_reprise <- !file.exists(chemin_clean)
if (mode_reprise) {
  chemin_clean <- "data/noria_clean_reprise.csv"
  message("Mode reprise : ce CSV fourni ne prouve pas votre nettoyage du TP02.")
}
if (!file.exists(chemin_clean)) stop("Exécutez TP02 ou demandez le CSV data/noria_clean_reprise.csv.")
clean <- read.csv(chemin_clean, na.strings = c("", "NA"), stringsAsFactors = FALSE,
  colClasses = c("integer", "character", "numeric", "numeric", "numeric", "character"))
clean$workflow <- factor(clean$workflow, levels = c("A", "B"))
clean$team <- factor(clean$team, levels = c("Atlas", "Boreal", "Cedre"))
stopifnot(nrow(clean) == 236, !anyNA(clean$resolution_minutes),
  !anyNA(clean$workflow), all(clean$resolution_minutes > 0))
a <- clean$resolution_minutes[clean$workflow == "A"]
b <- clean$resolution_minutes[clean$workflow == "B"]
# x = B et y = A donnent bien B moins A, en minutes.
test_welch <- t.test(x = b, y = a, var.equal = FALSE, conf.level = 0.95)
delta <- mean(b) - mean(a)
ic95 <- unname(test_welch$conf.int)
p_valeur <- test_welch$p.value
comparaison <- data.frame(contraste = "B - A", delta_minutes = delta,
  ic_bas = ic95[1], ic_haut = ic95[2], p_valeur = p_valeur)
# Un htest est une liste S3 : les composantes sont accessibles par leur nom.
classe_test <- class(test_welch)
attributs_test <- attributes(test_welch)
noms_test <- names(test_welch)
erreur_attendue <- try(t.test(c(1), c(2)), silent = TRUE)
interpretation_tp03 <- c(
  sprintf("B - A = %.2f minutes : B est plus rapide en moyenne sur les tickets observés.", delta),
  sprintf("IC95 [%.2f ; %.2f], p = %.4g ; l'IC décrit l'incertitude sur la différence moyenne.", ic95[1], ic95[2], p_valeur),
  "L'affectation est aléatoire dans cette simulation ; les exclusions et la transposition à de vrais tickets limitent la conclusion.")
dir.create("results", showWarnings = FALSE)
write.csv(comparaison, "results/TP03_comparaison.csv", row.names = FALSE)
pdf("results/TP03_resultats.pdf", width = 8, height = 5)
boxplot(resolution_minutes ~ workflow, data = clean, xlab = "Workflow",
  ylab = "Durée de résolution (minutes)", main = "Noria : comparaison descriptive")
plot(delta, 1, xlim = range(c(ic95, 0)), ylim = c(0.5, 1.5), yaxt = "n",
  xlab = "Différence moyenne B - A (minutes)", ylab = "", main = "Welch : IC à 95 %")
segments(ic95[1], 1, ic95[2], 1, lwd = 3)
abline(v = 0, lty = 2)
text(delta, 1.25, sprintf("Estimation : %.2f min", delta))
dev.off()
source("checks/TP03.R", local = TRUE, encoding = "UTF-8")
