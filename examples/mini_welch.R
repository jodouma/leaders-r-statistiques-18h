# Exemple AVANT TP03 : deux échantillons indépendants, pas des paires.
a_mini <- c(10,12,14,16)
b_mini <- c(8,10,12,14)
# Papier : A=13, B=11, B-A=-2 ; l'IC décrit l'incertitude, pas une durée individuelle.
test_mini <- t.test(x=b_mini,y=a_mini,var.equal=FALSE,conf.level=.95)
class(test_mini)            # "htest" : une liste avec classe S3.
attributes(test_mini)       # Noms et classe, pas seulement les nombres.
names(test_mini)            # Où chercher conf.int et p.value ?
delta_mini <- mean(b_mini)-mean(a_mini)
ic_mini <- unname(test_mini$conf.int)
p_mini <- test_mini$p.value
resultat_mini <- data.frame(contraste="B - A",delta_minutes=delta_mini,
  ic_bas=ic_mini[1],ic_haut=ic_mini[2],p_valeur=p_mini)
# Cas insuffisant intentionnel : observer une erreur en conservant l'exécution.
erreur_mini <- try(t.test(c(1),c(2)),silent=TRUE)
stopifnot(inherits(test_mini,"htest"),delta_mini == -2,inherits(erreur_mini,"try-error"))
print(resultat_mini)
# p n'est pas P(H0 vraie). Un IC contenant 0 ne démontre pas une égalité.
# Un point estimé, son intervalle horizontal et une référence à zéro.
# Toutes les valeurs proviennent du mini-test ci-dessus, sans données Noria.
dir.create("results", showWarnings = FALSE)
pdf("results/mini_welch_ic.pdf", width = 7, height = 4)
plot(delta_mini, 1, pch = 19, xlim = range(c(ic_mini, 0)),
  ylim = c(0.6, 1.4), yaxt = "n", ylab = "",
  xlab = "Différence moyenne B - A (minutes)",
  main = "Exemple jouet : estimation et IC à 95 %")
segments(ic_mini[1], 1, ic_mini[2], 1, lwd = 2)
abline(v = 0, lty = 2, col = "grey40")
dev.off()
# Le point est négatif, mais l'IC traverse zéro : ne pas conclure à une égalité.

# Lire une formule de graphique : « duree selon workflow ».
# ~ relie ici la variable numérique à la variable de groupe ; il ne fait pas un test.
mini_table <- data.frame(workflow = rep(c("A", "B"), each = 4),
                         duree = c(a_mini, b_mini))
pdf("results/mini_welch_distributions.pdf", width = 7, height = 4)
boxplot(duree ~ workflow, data = mini_table,
  xlab = "Workflow", ylab = "Durée (min)", main = "Deux distributions jouets")
hist(mini_table$duree, xlab = "Durée (min)", main = "Huit durées jouets")
dev.off()
