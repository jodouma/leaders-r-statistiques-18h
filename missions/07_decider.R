# Executer depuis la racine du dossier r-statistiques-18h.
# R base uniquement. Monnaie : TND.
# Mission 7 - Choisir et partager (3 points)
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
# Le bilan est reconstruit. Le lire avec print(bilan_produits).
# 1. Quel produit a le plus grand chiffre d'affaires ?
produit_prioritaire <- NULL
# 2. Sa part : chiffre d'affaires Sandwich / chiffre d'affaires total * 100.
part_sandwich <- NULL
# 3. Exporter le bilan dans outputs/07_bilan_produits.csv (row.names=FALSE).
# 4. writeLines() enregistre une courte decision dans outputs/07_decision.txt.
# Mentionner Sandwich, sa part, et rappeler que le chiffre d'affaires n'est pas la marge.
