# Executer depuis la racine du dossier du cours.
# R base uniquement. Monnaie : TND.
# EXEMPLE RESOLU : petit carnet d'entrainement, distinct du carnet a traiter.
mini <- read.csv("data/orders_mini.csv", stringsAsFactors = FALSE)
mini_sale <- rbind(mini, mini[1, ], mini[2, ]) # rbind colle des lignes
mini_sale$quantite[5] <- NA  # NA veut dire : information manquante
mini_unique <- unique(mini_sale)
mini_attente <- mini_unique[is.na(mini_unique$quantite), ]
mini_propre <- mini_unique[!is.na(mini_unique$quantite), ]
print(nrow(mini_unique)) # 4 : le doublon exact a disparu
print(nrow(mini_attente)) # 1
print(nrow(mini_propre)) # 3
# A vous : faire ce travail sur le vrai carnet, puis exporter les deux tables.
