# Executer depuis la racine du dossier r-statistiques-18h.
# R base uniquement. Monnaie : TND.
# EXEMPLE RESOLU : dessiner les recettes des trois lignes du mini-carnet.
mini <- read.csv("data/orders_mini.csv", stringsAsFactors = FALSE)
mini$chiffre_affaires <- mini$quantite * mini$prix_unitaire
dir.create("outputs", showWarnings = FALSE)
# png ouvre un fichier graphique; dev.off le ferme et finit son enregistrement.
png("outputs/exemple_06_mini.png", width = 900, height = 600)
barplot(mini$chiffre_affaires, names.arg = mini$produit,
        main = "Mini-carnet : recettes", ylab = "TND", col = "steelblue")
dev.off()
# A vous : dessiner les bilans de la semaine, puis dessiner la marge.
