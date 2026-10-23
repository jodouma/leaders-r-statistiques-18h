# Pont de langage : mêmes nombres, plusieurs structures. 15 minutes guidées.
# Ne remplace pas le TP02 : transférez seulement le geste d'écrire une fonction.
x <- c(10,20,30,40)
# Une fonction nomme un calcul réutilisable ; x est son entrée, le dernier calcul sa sortie.
resumer_mini <- function(x) {
  if (!is.numeric(x) || length(x)<2 || anyNA(x)) stop("Fournir au moins deux nombres sans NA.")
  c(n=length(x),moyenne=mean(x),ecart_type=sd(x))
}
resumer_mini(x)             # n=4 ; moyenne=25 ; sd~12,91.
resumer_mini(c(5,15))       # Autre entrée, même contrat.
# Une matrice contient ici un seul type ; deux lignes de trois colonnes.
m <- matrix(c(10,20,30,40,50,60),nrow=2,byrow=TRUE)
rownames(m) <- c("A","B")
colnames(m) <- c("t1","t2","t3")
m[1,2]                     # 20 : ligne 1, colonne 2.
apply(m,1,mean)             # 1 = lignes : A=20, B=50.
apply(m,2,mean)             # 2 = colonnes : 25,35,45.
# Une boucle explicite le même travail ; elle n'est pas nécessaire au TP03.
moyennes <- numeric(nrow(m))
for (i in seq_len(nrow(m))) {
  moyennes[i] <- mean(m[i, ])
}
stopifnot(all(moyennes == apply(m,1,mean)))
# Une liste peut contenir plusieurs types, accessibles par leur nom.
boite <- list(tableau=m,description="Deux séries illustratives",resume=resumer_mini(x))
class(boite)
names(boite)
attributes(m)              # dim et dimnames ; les nombres seuls ne disent pas tout.
boite$resume
# Transfert TP02 : remplacer les calculs de resumer_mini par les six statistiques demandées.

# quantile() renvoie un nombre ET une étiquette automatique, ici "25%".
# c() réunit les noms : ajouter q1= sans retirer l'étiquette donne "q1.25%".
q <- quantile(c(10,20,30), .25, type = 7)
names(q)                   # "25%" : le nom, pas la valeur du quartile.
quartile_avec_nom <- c(q1 = q)
quartile_sans_nom <- c(q1 = unname(q))
quartile_avec_nom           # q1.25% = 15 : le nom a été assemblé.
quartile_sans_nom           # q1 = 15 : unname() retire le nom, pas la valeur.
# Transfert : c(q1 = unname(quantile(x, .25, type = 7))) ; même geste pour q3.
# as.list() puis data.frame() conservent ces noms : vérifiez names(descriptifs).

# Passer d'un vecteur nommé à une ligne, puis réunir deux groupes.
resumer_mini <- function(x) c(n=length(x), moyenne=mean(x), ecart_type=sd(x))
ra <- resumer_mini(c(10,20,30))
rb <- resumer_mini(c(20,30,40))
ligne_a <- data.frame(workflow="A", as.list(ra))
ligne_b <- data.frame(workflow="B", as.list(rb))
mini_resume <- rbind(ligne_a, ligne_b)
rownames(mini_resume) <- NULL
print(mini_resume)
