# Executer depuis la racine du dossier du cours.
# R base uniquement. Monnaie : TND.
# Corrige 1 - Calculer un panier
prix_cafe <- 3
quantite_cafe <- 2
prix_the <- 5
quantite_the <- 1
prix_sandwich <- 8
quantite_sandwich <- 1
total_panier <- prix_cafe * quantite_cafe + prix_the * quantite_the +
  prix_sandwich * quantite_sandwich
cout_panier <- 1 * quantite_cafe + 2 * quantite_the + 3 * quantite_sandwich
marge_panier <- total_panier - cout_panier
print(total_panier)
print(cout_panier)
print(marge_panier)
