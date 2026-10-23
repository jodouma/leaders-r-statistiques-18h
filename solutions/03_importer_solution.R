# Executer depuis la racine du dossier du cours.
# R base uniquement. Monnaie : TND.
# Corrige 3 - Ouvrir le carnet de commandes
commandes <- read.csv("data/orders_raw.csv", stringsAsFactors = FALSE)
premiere_commande <- commandes[1, ]
produits <- unique(commandes$produit)
print(dim(commandes))
print(premiere_commande)
print(produits)
