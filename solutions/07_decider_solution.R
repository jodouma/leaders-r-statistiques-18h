# Executer depuis la racine du dossier r-statistiques-18h.
# R base uniquement. Monnaie : TND.
# Corrige 7 - Choisir et partager
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
print(bilan_produits)
produit_prioritaire <- "Sandwich"
ca_sandwich <- bilan_produits$chiffre_affaires[bilan_produits$produit == "Sandwich"]
part_sandwich <- ca_sandwich / sum(bilan_produits$chiffre_affaires) * 100
dir.create("outputs", showWarnings = FALSE)
write.csv(bilan_produits, "outputs/07_bilan_produits.csv", row.names = FALSE)
writeLines(c("Priorite : suivre le stock de Sandwich.",
             paste("Sandwich represente", part_sandwich, "% du chiffre d'affaires."),
             "Son chiffre d'affaires est de 40 TND; sa marge est de 25 TND.",
             "Ce petit carnet de quatre jours ne prouve pas les ventes futures."),
           "outputs/07_decision.txt")
print(part_sandwich)
