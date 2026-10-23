# Executer depuis la racine du dossier du cours.
# R base uniquement. Monnaie : TND.
# Mission 5 - Construire les bilans
# Lire votre fichier de mission 4 s'il existe.
# Sinon, le fichier de reference permet de commencer cette mission seule.
# Ce secours NE valide PAS votre mission 4 : lancez son controle separement.
chemin_propres <- "outputs/04_commandes_propres.csv"
if (!file.exists(chemin_propres)) {
  chemin_propres <- "data/orders_clean_reference.csv"
  message("Secours explicite : reference propre. La mission 4 reste a verifier.")
}
propres <- read.csv(chemin_propres, stringsAsFactors = FALSE)
# 1. Ajouter chiffre_affaires, cout_total et marge a propres.
# Chaque ligne : quantite * prix, quantite * cout, puis difference.
# TODO : ecrire les trois affectations propres$nom <- calcul.
# 2. Regrouper avec aggregate(). Modele explique dans examples/05_analyser_exemple.R.
bilan_produits <- NULL
bilan_jours <- NULL
total_ca <- NULL
total_marge <- NULL
# 3. Exporter bilan_produits dans outputs/05_bilan_produits.csv sans noms de lignes.
