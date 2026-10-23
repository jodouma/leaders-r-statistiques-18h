source("checks/check_tools.R")
controle_direct <- !interactive() && sys.nframe() == 0L
controle <- run_check("02_semaine", 2, function(s, check) {
  check("quatre chiffres d'affaires dans l'ordre des jours", 1,
        eq_num(s("ventes_journalieres"), c(19,27,33,21)))
  check("total de 100 TND et moyenne de 25 TND par jour", 1,
        eq_num(s("total_semaine"),100) && eq_num(s("moyenne_jour"),25))
}, use_cli_args = controle_direct)

# source() affiche le resultat sans fermer votre session RStudio.
# Seul Rscript, lance directement sur ce fichier, recoit un code de sortie.
if (controle_direct) quit(status = if (controle$ok) 0 else 1)
