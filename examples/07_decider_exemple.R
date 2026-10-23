# Executer depuis la racine du dossier du cours.
# R base uniquement. Monnaie : TND.
# EXEMPLE RESOLU : un message prudent a partir du panier de depart.
ca_cafe <- 6
ca_panier <- 19
part_cafe <- ca_cafe / ca_panier * 100
print(part_cafe) # environ 31.6 pour cent, pas 6 pour cent
dir.create("outputs", showWarnings = FALSE)
# c() rassemble plusieurs lignes de texte. paste() assemble texte et nombre.
writeLines(c("Mini-carnet : observer les cafes.",
             paste("Part du cafe :", round(part_cafe, 1), "% du panier.")),
           "outputs/exemple_07_message.txt")
# write.csv(table, "chemin.csv", row.names=FALSE) partage une table.
# A vous : choisir le produit de la semaine et partager son vrai bilan.
