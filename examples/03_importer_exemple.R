# Executer depuis la racine du dossier du cours.
# R base uniquement. Monnaie : TND.
# EXEMPLE RESOLU : passer de trois lignes connues au vrai carnet.
mini <- read.csv("data/orders_mini.csv", stringsAsFactors = FALSE)
print(mini)
print(nrow(mini)) # 3
print(mini[1, ])  # une ligne et toutes les colonnes
print(mini$produit)
print(unique(mini$produit))
# A vous : ouvrir orders_raw.csv et examiner ses 14 lignes.
