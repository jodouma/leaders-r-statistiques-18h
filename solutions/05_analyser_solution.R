# Executer depuis la racine du dossier du cours.
# R base uniquement. Monnaie : TND.
# Corrige 5 - Construire les bilans
# Lire votre fichier de mission 4 s'il existe.
# Sinon, le fichier de reference permet de commencer cette mission seule.
# Ce secours NE valide PAS votre mission 4 : lancez son controle separement.
chemin_propres <- "outputs/04_commandes_propres.csv"
if (!file.exists(chemin_propres)) {
  chemin_propres <- "data/orders_clean_reference.csv"
  message("Secours explicite : reference propre. La mission 4 reste a verifier.")
}
propres <- read.csv(chemin_propres, stringsAsFactors = FALSE)
propres$chiffre_affaires <- propres$quantite * propres$prix_unitaire
propres$cout_total <- propres$quantite * propres$cout_unitaire
propres$marge <- propres$chiffre_affaires - propres$cout_total
bilan_produits <- aggregate(cbind(chiffre_affaires, cout_total, marge) ~ produit,
                           data = propres, FUN = sum)
bilan_jours <- aggregate(cbind(chiffre_affaires, cout_total, marge) ~ date,
                        data = propres, FUN = sum)
total_ca <- sum(propres$chiffre_affaires)
total_marge <- sum(propres$marge)
dir.create("outputs", showWarnings = FALSE)
write.csv(bilan_produits, "outputs/05_bilan_produits.csv", row.names = FALSE)
print(bilan_produits)
print(bilan_jours)
print(total_ca)
print(total_marge)
