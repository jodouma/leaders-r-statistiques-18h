# Le CSV de reprise autorise la comparaison, pas la validation du nettoyage TP02.
source("checks/_utils.R", local = TRUE, encoding = "UTF-8")
d <- besoin("clean")
verifier(nrow(d)==236 && identical(as.integer(table(d$workflow)),c(117L,119L)), "contrôler le tableau d'entrée de la comparaison.")
verifier(proche(besoin("a"), d$resolution_minutes[d$workflow=="A"]) &&
  proche(besoin("b"),d$resolution_minutes[d$workflow=="B"]), "extraire les deux groupes sans les inverser.")
verifier_comparaison(besoin("comparaison"),besoin("test_welch"),d)
verifier(identical(besoin("classe_test"),class(test_welch)), "examiner class(test_welch).")
verifier(identical(besoin("attributs_test"),attributes(test_welch)), "examiner attributes(test_welch).")
verifier(identical(besoin("noms_test"),names(test_welch)), "examiner names(test_welch) avant de choisir une composante.")
verifier(proche(besoin("delta"),comparaison$delta_minutes) &&
  proche(besoin("ic95"),c(comparaison$ic_bas,comparaison$ic_haut)) &&
  proche(besoin("p_valeur"),comparaison$p_valeur), "nommer et extraire delta, ic95 et p_valeur.")
verifier(inherits(besoin("erreur_attendue"),"try-error"), "capturer l'erreur d'effectif insuffisant avec try().")
verifier(texte_personnel(besoin("interpretation_tp03")), "écrire trois phrases sur taille, incertitude et limites.")
verifier_csv("results/TP03_comparaison.csv",comparaison)
verifier_pdf("results/TP03_resultats.pdf")
message("TP03 : contrôles réussis.")
