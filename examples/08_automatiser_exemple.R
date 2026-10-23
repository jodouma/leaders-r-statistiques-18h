# Executer depuis la racine du dossier r-statistiques-18h.
# R base uniquement. Monnaie : TND.
# EXEMPLE RESOLU : nommer un calcul simple avant de nommer toute l'analyse.
calculer_recette <- function(quantite, prix) {
  quantite * prix
}
print(calculer_recette(2, 3)) # 6 : les arguments deviennent les valeurs locales
print(calculer_recette(1, 8)) # 8 : meme recette, autres arguments
# La derniere expression est le resultat rendu par la fonction.
# A vous : une fonction avec un chemin, puis lecture, nettoyage et bilan.
