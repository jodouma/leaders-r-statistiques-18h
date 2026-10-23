source("checks/check_tools.R")
controle_direct <- !interactive() && sys.nframe() == 0L
controle <- run_check("05_analyser", 3, function(s, check) {
  clean <- read.csv("data/orders_clean_reference.csv", stringsAsFactors=FALSE)
  clean$chiffre_affaires <- clean$quantite * clean$prix_unitaire
  clean$cout_total <- clean$quantite * clean$cout_unitaire
  clean$marge <- clean$chiffre_affaires - clean$cout_total
  check("trois colonnes calculees sur les 12 commandes completes", 1,
        table_same(s("propres"),clean,"id"))
  check("bilan par produit et export CSV", 1,
        table_same(s("bilan_produits"),expected_products(),"produit") &&
        table_same(read_output("outputs/05_bilan_produits.csv"),expected_products(),"produit"))
  check("bilan par jour, total CA 100 TND et marge 63 TND", 1,
        table_same(s("bilan_jours"),expected_days(),"date") &&
        eq_num(s("total_ca"),100) && eq_num(s("total_marge"),63))
}, use_cli_args = controle_direct)

# source() affiche le resultat sans fermer votre session RStudio.
# Seul Rscript, lance directement sur ce fichier, recoit un code de sortie.
if (controle_direct) quit(status = if (controle$ok) 0 else 1)
