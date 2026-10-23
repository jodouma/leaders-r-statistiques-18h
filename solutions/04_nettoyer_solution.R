# Executer depuis la racine du dossier r-statistiques-18h.
# R base uniquement. Monnaie : TND.
# Corrige 4 - Nettoyer sans inventer
commandes <- read.csv("data/orders_raw.csv", stringsAsFactors = FALSE)
sans_doublon <- unique(commandes)
a_completer <- sans_doublon[is.na(sans_doublon$quantite), ]
propres <- sans_doublon[!is.na(sans_doublon$quantite), ]
# Ne pas remplacer une valeur inconnue par 0 : cela inventerait une information.
dir.create("outputs", showWarnings = FALSE)
write.csv(propres, "outputs/04_commandes_propres.csv", row.names = FALSE)
write.csv(a_completer, "outputs/04_commandes_a_completer.csv", row.names = FALSE)
print(nrow(propres))
print(a_completer)
