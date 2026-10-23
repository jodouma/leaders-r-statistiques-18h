# EXTENSION FACULTATIVE — hors tronc commun de 18 h. R de base uniquement.
# Depuis la racine : source("examples/mini_bootstrap.R", encoding = "UTF-8")
# Question : comment la différence B-A varie-t-elle par rééchantillonnage ?
# delta*(b) = mean(B*(b)) - mean(A*(b)), en minutes ; * = tirage avec remise.
# IC percentile = [Q_0.025(delta*), Q_0.975(delta*)], quantiles type 7.
# Papier : A*=(10,10,14), B*=(8,12,12) -> delta*=32/3 - 34/3 = -2/3 min.
delta_un_tirage <- mean(c(8, 12, 12)) - mean(c(10, 10, 14))
stopifnot(abs(delta_un_tirage - (-2/3)) < 1e-12)
print(delta_un_tirage)

# Priorité au CSV produit par votre TP02 ; la reprise permet de découvrir l'option.
# Aucun source() des modules de référence n'est nécessaire.
chemin_option <- "results/TP02_clean.csv"
if (!file.exists(chemin_option)) {
  chemin_option <- "data/noria_clean_reprise.csv"
  message("CSV de reprise fourni : ceci ne valide pas votre nettoyage du TP02.")
}
if (!file.exists(chemin_option)) stop("Ouvrir course.Rproj, puis lancer depuis sa racine.")
option_d <- read.csv(chemin_option, na.strings = c("", "NA"),
  stringsAsFactors = FALSE, fileEncoding = "UTF-8",
  colClasses = c("integer", "character", "numeric", "numeric", "numeric", "character"))
stopifnot(nrow(option_d) > 1L, !anyNA(option_d$ticket_id),
  !anyDuplicated(option_d$ticket_id), all(is.finite(option_d$resolution_minutes)),
  all(option_d$resolution_minutes > 0), !anyNA(option_d$workflow),
  all(option_d$workflow %in% c("A", "B")),
  all(c("A", "B") %in% option_d$workflow))

a_option <- option_d$resolution_minutes[option_d$workflow == "A"]
b_option <- option_d$resolution_minutes[option_d$workflow == "B"]
stopifnot(length(a_option) >= 2L, length(b_option) >= 2L)
set.seed(2026)
n_repetitions <- 5000L
# Tirer séparément conserve les tailles des deux groupes indépendants.
delta_etoile <- replicate(n_repetitions, {
  a_etoile <- sample(a_option, length(a_option), replace = TRUE)
  b_etoile <- sample(b_option, length(b_option), replace = TRUE)
  mean(b_etoile) - mean(a_etoile)
})
ic_bootstrap <- quantile(delta_etoile, c(.025, .975), type = 7, names = FALSE)
resultat_bootstrap <- data.frame(contraste = "B - A", unite = "minutes",
  estimation = mean(b_option) - mean(a_option),
  ic_bas = ic_bootstrap[1], ic_haut = ic_bootstrap[2], repetitions = n_repetitions)
print(resultat_bootstrap)
# Facultatif : hist(delta_etoile, xlab="Difference B-A (minutes)").
# Hypothèses : tickets indépendants dans et entre les groupes ; l'échantillon
# représente les populations visées. Des grappes/mesures répétées exigent un autre
# plan de rééchantillonnage. Le bootstrap ne répare ni sélection ni données absentes.
# L'IC percentile peut différer de Welch ; ce n'est pas un IC de durées individuelles.
# Fixer la méthode avant les résultats, sans choisir l'IC selon son passage par zéro.
# Plus de tirages réduit l'erreur Monte-Carlo des bornes, pas les biais de données.
# La graine rend le tirage relançable ; elle ne garantit pas la qualité de l'IC.
# Le tirage manuel de 3 valeurs montre le geste, pas une fiabilité à petit effectif.
