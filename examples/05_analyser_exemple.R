# Executer depuis la racine du dossier du cours.
# R base uniquement. Monnaie : TND.
# EXEMPLE RESOLU : calculer et regrouper les trois lignes du mini-carnet.
mini <- read.csv("data/orders_mini.csv", stringsAsFactors = FALSE)
mini$chiffre_affaires <- mini$quantite * mini$prix_unitaire
mini$cout_total <- mini$quantite * mini$cout_unitaire
mini$marge <- mini$chiffre_affaires - mini$cout_total
# cbind rassemble les colonnes a additionner; ~ date dit : par date.
bilan_mini <- aggregate(cbind(chiffre_affaires, cout_total, marge) ~ date,
                        data = mini, FUN = sum)
print(bilan_mini) # chiffre_affaires=19, cout_total=7, marge=12
# A vous : appliquer ces gestes aux 12 commandes, par produit puis par jour.
