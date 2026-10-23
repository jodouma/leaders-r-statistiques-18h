# Contrôle autonome du projet : objets personnels, audit et livrables.
source("checks/_utils.R", local = TRUE, encoding = "UTF-8")
verifier(is.data.frame(besoin("raw4")) && nrow(raw4)==241 && sum(duplicated(raw4$ticket_id))==1,
  "repartir du CSV brut et conserver raw4 intact.")
verifier(is.function(besoin("nettoyer_projet")) && is.function(besoin("decrire_projet")), "écrire les deux fonctions du projet.")
verifier_audit(besoin("audit4"))
verifier_clean(besoin("clean4"),besoin("exclusions4"))
verifier_descriptifs(besoin("descriptifs4"),clean4)
verifier_comparaison(besoin("comparaison4"),besoin("test4"),clean4)
verifier(proche(besoin("seuil_utile4"),5), "appliquer le critère du protocole pédagogique : gain utile de 5 minutes.")
zone_attendue <- if (comparaison4$ic_haut < -seuil_utile4) "gain_etaye" else
  if (comparaison4$ic_bas < -seuil_utile4) "gain_possible" else "gain_non_etaye"
verifier(identical(besoin("zone_decision4"),zone_attendue), "décision : comparer tout l'IC au seuil -5, pas seulement p à 0,05.")
verifier(texte_personnel(besoin("recommandation4")), "rédiger une recommandation personnelle avec au moins trois phrases.")
texte <- paste(recommandation4,collapse=" ")
verifier(grepl("IC|intervalle",texte,ignore.case=TRUE) && grepl("5",texte) &&
  grepl("incertain|incertitude|possible",texte,ignore.case=TRUE) &&
  grepl("pilote|suivi|réévalu|reevalu|mesur",texte,ignore.case=TRUE),
  "recommandation : expliciter IC, seuil de 5 min, incertitude et prochaine action.")
verifier_csv("results/TP04_audit.csv",audit4)
verifier_csv("results/TP04_exclusions.csv",exclusions4)
verifier_csv("results/TP04_descriptifs.csv",descriptifs4)
verifier_csv("results/TP04_comparaison.csv",comparaison4)
verifier_pdf("results/TP04_graphiques.pdf")
verifier_pdf("results/TP04_recommandation.pdf")
verifier(file.exists("results/TP04_recommandation.txt"), "exporter la recommandation aussi en texte.")
verifier(identical(readLines("results/TP04_recommandation.txt",warn=FALSE,encoding="UTF-8"),recommandation4),
  "le texte exporté doit correspondre à recommandation4.")
verifier(inherits(besoin("session4"), "sessionInfo"), "créer session4 avec sessionInfo().")
verifier(identical(session4$R.version$version.string, R.version$version.string),
  "session4 doit décrire la session R qui a exécuté votre analyse.")
verifier(file.exists("results/TP04_sessionInfo.txt"),
  "exporter session4 avec writeLines(capture.output(session4), ...).")
verifier(identical(readLines("results/TP04_sessionInfo.txt", warn = FALSE), capture.output(session4)),
  "TP04_sessionInfo.txt doit contenir la sortie de votre objet session4.")
message("TP04 : contrôles réussis. Relire humainement la recommandation et sa page PDF.")
