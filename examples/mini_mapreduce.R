# EXTENSION FACULTATIVE — hors tronc commun de 18 h. R de base uniquement.
# Depuis la racine : source("examples/mini_mapreduce.R", encoding = "UTF-8")
# Idée locale de MapReduce : aucun Hadoop/RHadoop, aucune exécution distribuée.
# Morceau k : S_k = somme des x_ki (minutes), n_k = nombre de tickets.
# Moyenne globale = somme_k(S_k) / somme_k(n_k), en minutes.
# Papier : [10,20] et [30] -> S=(30,30), n=(2,1) -> 60/3=20 min.
# Piège : moyenne des moyennes = (15+30)/2=22.5 min, incorrecte ici.
morceaux_jouets <- list(c(10, 20), c(30))
sommes_jouets <- vapply(morceaux_jouets, sum, numeric(1))
effectifs_jouets <- vapply(morceaux_jouets, length, integer(1))
moyenne_fusionnee <- sum(sommes_jouets) / sum(effectifs_jouets)
stopifnot(moyenne_fusionnee == 20,
  mean(vapply(morceaux_jouets, mean, numeric(1))) == 22.5)
print(moyenne_fusionnee)

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

x_option <- option_d$resolution_minutes
stopifnot(length(x_option) > 60L)
# Trois morceaux volontairement inégaux : 7, 53, puis tous les tickets restants.
lot <- rep(1:3, times = c(7L, 53L, length(x_option) - 60L))
morceaux <- split(x_option, lot)
# MAP : vapply produit un résumé de type fixé pour chaque morceau.
sommes <- vapply(morceaux, sum, numeric(1))
effectifs <- vapply(morceaux, length, integer(1))
# REDUCE : additionner les résumés, puis diviser. sum() est aussi une réduction.
moyenne_reduite <- Reduce(`+`, sommes) / Reduce(`+`, effectifs)
stopifnot(abs(moyenne_reduite - mean(x_option)) < 1e-10)
print(data.frame(lot = names(morceaux), somme_minutes = sommes,
  n = effectifs, moyenne_minutes = sommes / effectifs))
print(data.frame(methode = c("somme/effectif", "moyenne des moyennes (incorrecte)"),
  minutes = c(moyenne_reduite, mean(sommes / effectifs))))
# Même règle de validité dans tous les morceaux ; ne pas compter NA comme 0.
# La médiane ne se fusionne pas à partir des seules médianes locales.
# Une variance nécessite plus d'informations (ou une formule de fusion dédiée).
# Ici on illustre l'agrégation : aucune infrastructure RHadoop à installer.
