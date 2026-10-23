# Executer depuis la racine du dossier r-statistiques-18h.
# R base uniquement. Monnaie : TND.
# Mission 6 - Dessiner deux comparaisons (3 points)
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
# Le bilan precedent est reconstruit ici pour rendre cette mission autonome.
# 1. Creer outputs puis ouvrir png("outputs/06_ca_produits.png", width=900, height=600).
# 2. barplot() : hauteurs = chiffre_affaires, names.arg = produit, axe y en TND.
# 3. Fermer avec dev.off().
# 4. Recommencer avec marge et outputs/06_marge_produits.png.
# Deux fichiers differents : chiffre d'affaires et marge ne racontent pas la meme chose.
