source("checks/check_tools.R")
controle_direct <- !interactive() && sys.nframe() == 0L
controle <- run_check("08_automatiser", function(s, check) {
  check("les deux carnets traites et le second resume exporte",
        table_same(s("resultat_semaine_1"),expected_summary()) &&
        table_same(s("resultat_semaine_2"),expected_summary(TRUE)) &&
        table_same(read_output("outputs/08_resume_semaine_2.csv"),expected_summary(TRUE)))
  f <- s("resumer_commandes")
  # Nouveau petit carnet : le controle n'attend pas une fonction a nombres fixes.
  nouveau <- data.frame(id=c("N1","N2","N1","N3"), date="2026-10-20",
                        produit=c("Cafe","The","Cafe","Sandwich"),
                        quantite=c(4,2,4,NA), prix_unitaire=c(3,5,3,8),
                        cout_unitaire=c(1,2,1,3))
  write.csv(nouveau,"data/nouveau_controle.csv",row.names=FALSE)
  calcul <- tryCatch(if (is.function(f)) f("data/nouveau_controle.csv") else NULL,
                     error=function(e) NULL)
  attendu <- data.frame(chiffre_affaires=22,cout_total=8,marge=14,quantite=6,n_commandes=2)
  check("fonction reutilisable : nouveau fichier, doublon et quantite absente",
        table_same(calcul,attendu))
}, use_cli_args = controle_direct)

# source() affiche le resultat sans fermer votre session RStudio.
# Seul Rscript, lance directement sur ce fichier, recoit un code de sortie.
if (controle_direct) quit(status = if (controle$ok) 0 else 1)
