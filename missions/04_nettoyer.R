# Executer depuis la racine du dossier r-statistiques-18h.
# R base uniquement. Monnaie : TND.
# Mission 4 - Nettoyer sans inventer (2 points)
commandes <- read.csv("data/orders_raw.csv", stringsAsFactors = FALSE)
# 1. Retirer seulement les lignes exactement identiques avec unique().
sans_doublon <- NULL
# 2. is.na() repere une quantite absente; ! inverse TRUE/FALSE.
# Garder les lignes incompletes a part, puis les lignes completes dans propres.
a_completer <- NULL
propres <- NULL
# 3. Creer outputs si besoin avec dir.create(..., showWarnings = FALSE).
# Exporter propres dans outputs/04_commandes_propres.csv (row.names = FALSE).
# Exporter a_completer dans outputs/04_commandes_a_completer.csv.
# Une quantite absente n'est pas zero. On attend l'information avant le total.
