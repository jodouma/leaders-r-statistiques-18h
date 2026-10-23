# Executer depuis la racine du dossier du cours.
# R base uniquement. Monnaie : TND.
# Corrige 8 - Recommencer avec une fonction
resumer_commandes <- function(chemin) {
  commandes <- read.csv(chemin, stringsAsFactors = FALSE)
  sans_doublon <- unique(commandes)
  propres <- sans_doublon[!is.na(sans_doublon$quantite), ]
  propres$chiffre_affaires <- propres$quantite * propres$prix_unitaire
  propres$cout_total <- propres$quantite * propres$cout_unitaire
  propres$marge <- propres$chiffre_affaires - propres$cout_total
  data.frame(chiffre_affaires = sum(propres$chiffre_affaires),
             cout_total = sum(propres$cout_total),
             marge = sum(propres$marge),
             quantite = sum(propres$quantite),
             n_commandes = nrow(propres))
}
resultat_semaine_1 <- resumer_commandes("data/orders_raw.csv")
resultat_semaine_2 <- resumer_commandes("data/orders_week2_raw.csv")
print(resultat_semaine_1)
print(resultat_semaine_2)
dir.create("outputs", showWarnings = FALSE)
write.csv(resultat_semaine_2, "outputs/08_resume_semaine_2.csv", row.names = FALSE)
