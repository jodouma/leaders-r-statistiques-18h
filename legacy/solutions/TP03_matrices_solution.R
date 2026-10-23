# ARCHIVE FACULTATIVE — ancien parcours à six TP, hors tronc commun de 18 h.
# Exécuter depuis la racine : source("legacy/solutions/TP03_matrices_solution.R")
source("scripts/00_check_setup.R", encoding = "UTF-8")
for (file in sort(list.files("R", pattern = "[.]R$", full.names = TRUE))) {
  source(file, encoding = "UTF-8")
}
# Corrigé TP03 — Matrices et contrats des fonctions.
m1 <- matrix(1:12, nrow = 3)
m2 <- matrix(1:12, nrow = 3, byrow = TRUE)
print(m1)                                   # lignes : 1,4,7,10 puis 2,5,8,11 puis 3,6,9,12
print(m2)                                   # lignes : 1,2,3,4 puis 5,6,7,8 puis 9,10,11,12
print(dim(m2[, 1]))                         # NULL : vecteur
print(dim(m2[, 1, drop = FALSE]))            # 3 1 : matrice
sums <- numeric(nrow(m2))
for (i in seq_len(nrow(m2))) sums[i] <- sum(m2[i, ])
print(sums)                                 # 10 26 42
print(apply(m2, 1, mean))                    # 2.5 6.5 10.5
print(safe_mean(c(2, NA_real_, 4)))         # 3
print(safe_mean(numeric(0)))                 # NA_real_
print(safe_mean(c(NA_real_, NA_real_)))       # NA_real_
print(try(safe_mean("10"), silent = TRUE))   # erreur intentionnelle, pas une conversion implicite
print(typeof(as.matrix(data.frame(nombre = 1:2, groupe = c("A", "B"))))) # "character"
m2[1, 2] <- -3
m2[m2 < 0] <- 0
stopifnot(identical(dim(m2), c(3L, 4L)), m2[1, 2] == 0)
# Une fonction sûre distingue données absentes, mauvais type et valeurs impossibles.

# Les noms sont des attributs : ils n'altèrent pas les calculs.
rownames(m1) <- paste0("ligne", 1:3)
colnames(m1) <- paste0("colonne", 1:4)
print(m1[2, 3])                             # 8 ; m2 initial[2,3] vaut7
print(m1[1:2, 2:3, drop = FALSE])
stopifnot(identical(unname(apply(m1, 2, sum)), c(6L, 15L, 24L, 33L)))
d <- clean_noria(read_noria())$data
cross <- table(d$complexity, d$workflow)
print(cross)
print(rowSums(cross))
print(colSums(cross))                        # A117 B119
stopifnot(sum(cross) == 236, identical(as.integer(colSums(cross)), c(117L, 119L)))
