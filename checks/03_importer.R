source("checks/check_tools.R")
controle_direct <- !interactive() && sys.nframe() == 0L
controle <- run_check("03_importer", 3, function(s, check) {
  raw <- read.csv("data/orders_raw.csv", stringsAsFactors=FALSE)
  check("table brute complete : 14 lignes et six colonnes utiles", 1,
        table_same(s("commandes"), raw, "id"))
  check("premiere commande : O001, Cafe, quantite 2", 1,
        table_same(s("premiere_commande"), raw[1, ]))
  check("les trois produits distincts", 1,
        length(s("produits")) == 3 &&
        setequal(as.character(s("produits")), c("Cafe","The","Sandwich")))
}, use_cli_args = controle_direct)

# source() affiche le resultat sans fermer votre session RStudio.
# Seul Rscript, lance directement sur ce fichier, recoit un code de sortie.
if (controle_direct) quit(status = if (controle$ok) 0 else 1)
