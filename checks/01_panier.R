source("checks/check_tools.R")
controle_direct <- !interactive() && sys.nframe() == 0L
controle <- run_check("01_panier", 2, function(s, check) {
  check("prix, quantites et chiffre d'affaires du panier", 1,
        eq_num(s("prix_cafe"),3) && eq_num(s("quantite_cafe"),2) &&
        eq_num(s("prix_the"),5) && eq_num(s("quantite_the"),1) &&
        eq_num(s("prix_sandwich"),8) && eq_num(s("quantite_sandwich"),1) &&
        eq_num(s("total_panier"),19))
  check("cout et marge du panier", 1,
        eq_num(s("cout_panier"),7) && eq_num(s("marge_panier"),12))
}, use_cli_args = controle_direct)

# source() affiche le resultat sans fermer votre session RStudio.
# Seul Rscript, lance directement sur ce fichier, recoit un code de sortie.
if (controle_direct) quit(status = if (controle$ok) 0 else 1)
