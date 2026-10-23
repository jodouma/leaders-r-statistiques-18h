# TP03 — Comparer deux moyennes indépendantes · durée indicative : 120 min · R de base, depuis la racine du projet.
# 1. Ouvrez course.Rproj ; ouvrez ce fichier dans l'éditeur.
# 2. Lisez la première consigne puis exécutez une ligne avec Ctrl/Cmd + Entrée.
# 3. Remplacez les TODO ; exécutez ensuite tout le fichier de haut en bas.
# 4. Lancez source("checks/TP03.R", encoding = "UTF-8").
# Résultat final attendu du contrôle : « TP03 : contrôles réussis. »
# Un contrôle rouge nomme l'objet à corriger ; ne copiez pas le corrigé.
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
# Avant le test : définir B - A, unité minute, H0 : moyennes égales.
# Les tickets sont indépendants et affectés au hasard dans ce cas simulé.
# Les données manquantes exclues restent une limite à examiner.
a <- numeric(0)               # TODO : durées de A, indexation logique.
b <- numeric(0)               # TODO : durées de B.
# Exemple autonome dans examples/mini_welch.R ; t.test(x = b, y = a) donne B-A.
test_welch <- NULL            # TODO : t.test, var.equal = FALSE, conf.level = 0.95.
classe_test <- character(0)   # TODO : class(test_welch).
attributs_test <- list()      # TODO : attributes(test_welch).
noms_test <- character(0)     # TODO : names(test_welch).
delta <- NA_real_             # TODO : mean(b) - mean(a).
ic95 <- c(NA_real_, NA_real_) # TODO : unname(test_welch$conf.int).
p_valeur <- NA_real_          # TODO : accès nommé avec $.
comparaison <- data.frame()   # TODO : contraste, delta_minutes, ic_bas, ic_haut, p_valeur.
# Une erreur provoquée et capturée : R refuse des effectifs insuffisants.
erreur_attendue <- try(t.test(c(1), c(2)), silent = TRUE)
# TODO : interprétation en 3 phrases : sens et taille, IC et incertitude, limite causale.
interpretation_tp03 <- c("TODO taille", "TODO intervalle et p", "TODO limites")
# TODO : CSV results/TP03_comparaison.csv ; PDF results/TP03_resultats.pdf :
# un boxplot avec unité, puis une page du contraste avec son IC et la ligne zéro.
# Seuls les objets créés ci-dessus doivent alimenter le PDF.
