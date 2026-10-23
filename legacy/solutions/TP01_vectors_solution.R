# ARCHIVE FACULTATIVE — ancien parcours à six TP, hors tronc commun de 18 h.
# Exécuter depuis la racine : source("legacy/solutions/TP01_vectors_solution.R")
source("scripts/00_check_setup.R", encoding = "UTF-8")
for (file in sort(list.files("R", pattern = "[.]R$", full.names = TRUE))) {
  source(file, encoding = "UTF-8")
}
# Corrigé TP01 — Résultats attendus explicités.
delais <- c(42, NA_real_, 35, 80, 55, NA_real_, 20, 60)
print(length(delais))                        # 8
print(mean(delais))                          # NA
print(typeof(is.na(delais)))                 # "logical"
observed <- delais[!is.na(delais)]
at_most_55 <- delais[!is.na(delais) & delais <= 55]
above_50 <- !is.na(delais) & delais > 50
print(observed)                              # 42 35 80 55 20 60
print(at_most_55)                            # 42 35 55 20
print(above_50)                              # FALSE FALSE FALSE TRUE TRUE FALSE FALSE TRUE
print(sum(is.na(delais)))                    # 2
print(sum(!is.na(delais)))                   # 6
print(sum(delais, na.rm = TRUE))             # 292
print(mean(delais, na.rm = TRUE))            # 48.6666666667
print(median(delais, na.rm = TRUE))          # 48.5
print(delais[1:3])                           # 42 NA 35
print(delais[-1])                            # NA 35 80 55 NA 20 60
print(delais[delais > 50])                    # NA 80 55 NA 60
print(delais[above_50])                      # 80 55 60
# Erreur intentionnelle et capturée : une chaîne ne s'ajoute pas à un nombre.
print(try("42" + 1, silent = TRUE))
print(as.numeric("42") + 1)                 # 43 ; conversion explicite après examen
stopifnot(length(observed) + sum(is.na(delais)) == length(delais),
          identical(delais[above_50], c(80, 55, 60)), sum(observed) == 292)
# Une comparaison inconnue sélectionne un NA ; le masque corrigé définit l'absence.
# Le nombre observé donne le dénominateur de la moyenne ; NA ne vaut pas zéro.
# Un résultat plausible doit être contrôlé par une propriété indépendante.

# Extension objets : le nom est un attribut ; la liste conserve différents types.
names(delais) <- paste0("position", seq_along(delais))
objects <- list(delais = delais, unit = "minutes", observed = observed)
str(objects)
print(attributes(delais))
print(is.na(c(NA_real_, NaN, Inf)))           # TRUE TRUE FALSE
print(is.finite(c(NA_real_, NaN, Inf)))       # FALSE FALSE FALSE
print(is.na(""))                             # FALSE
print(mean(c(TRUE, FALSE, TRUE)))            # 2/3
# Défi fonction : le cas vide et tout-NA reste absent, avec son effectif visible.
describe_vector <- function(x) {
  c(n_total = length(x), n_observed = sum(!is.na(x)), mean = safe_mean(x))
}
print(describe_vector(delais))               # 8 ; 6 ; 48.6666666667
print(describe_vector(numeric(0)))           # 0 ; 0 ; NA
print(describe_vector(c(NA_real_, NA_real_))) # 2 ; 0 ; NA
