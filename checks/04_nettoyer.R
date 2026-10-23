source("checks/check_tools.R")
controle_direct <- !interactive() && sys.nframe() == 0L
controle <- run_check("04_nettoyer", function(s, check) {
  raw <- read.csv("data/orders_raw.csv", stringsAsFactors=FALSE)
  clean <- read.csv("data/orders_clean_reference.csv", stringsAsFactors=FALSE)
  unique_rows <- unique(raw)
  waiting <- unique_rows[is.na(unique_rows$quantite), ]
  check("doublon exact retire; commande inconnue gardee a part",
        table_same(s("sans_doublon"),unique_rows,"id") &&
        table_same(s("a_completer"),waiting,"id") &&
        table_same(read_output("outputs/04_commandes_a_completer.csv"),waiting,"id"))
  check("12 commandes completes et export relisible sans colonne de noms de lignes",
        table_same(s("propres"),clean,"id") &&
        table_same(read_output("outputs/04_commandes_propres.csv"),clean,"id") &&
        setequal(names(read_output("outputs/04_commandes_propres.csv")),names(clean)))
}, use_cli_args = controle_direct)

# source() affiche le resultat sans fermer votre session RStudio.
# Seul Rscript, lance directement sur ce fichier, recoit un code de sortie.
if (controle_direct) quit(status = if (controle$ok) 0 else 1)
