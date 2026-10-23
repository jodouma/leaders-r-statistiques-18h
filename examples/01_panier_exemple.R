# Executer depuis la racine du dossier r-statistiques-18h.
# R base uniquement. Monnaie : TND.
# EXEMPLE RESOLU : une seule ligne du mini-carnet, 2 cafes.
# <- affecte une valeur; * multiplie; - calcule une difference.
prix <- 3
quantite <- 2
cout_unitaire <- 1
recette <- prix * quantite
cout <- cout_unitaire * quantite
marge <- recette - cout
print(recette) # 6
print(marge)   # 4
# A vous : le panier complet comporte aussi un the et un sandwich.
