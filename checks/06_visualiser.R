source("checks/check_tools.R")
controle_direct <- !interactive() && sys.nframe() == 0L
controle <- run_check("06_visualiser", 3, function(s, check) {
  check("donnees du bilan par produit exactes", 1,
        table_same(s("bilan_produits"),expected_products(),"produit"))
  check("image PNG du chiffre d'affaires creee par ce script", 1,
        valid_png("outputs/06_ca_produits.png"))
  check("image PNG de la marge creee par ce script", 1,
        valid_png("outputs/06_marge_produits.png"))
}, use_cli_args = controle_direct)

# source() affiche le resultat sans fermer votre session RStudio.
# Seul Rscript, lance directement sur ce fichier, recoit un code de sortie.
if (controle_direct) quit(status = if (controle$ok) 0 else 1)
