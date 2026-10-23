source("checks/check_tools.R")
controle_direct <- !interactive() && sys.nframe() == 0L
controle <- run_check("07_decider", function(s, check) {
  check("priorite Sandwich et part de 40 pour cent",
        identical(as.character(s("produit_prioritaire")),"Sandwich") &&
        eq_num(s("part_sandwich"),40))
  check("bilan exact partage en CSV",
        table_same(s("bilan_produits"),expected_products(),"produit") &&
        table_same(read_output("outputs/07_bilan_produits.csv"),expected_products(),"produit"))
  texte <- if (file.exists("outputs/07_decision.txt"))
    paste(readLines("outputs/07_decision.txt",warn=FALSE),collapse=" ") else ""
  check("decision en texte avec Sandwich, sa part et la marge",
        grepl("sandwich",texte,ignore.case=TRUE) && grepl("40",texte) &&
        grepl("%|pour cent",texte,ignore.case=TRUE) && grepl("marge",texte,ignore.case=TRUE))
}, use_cli_args = controle_direct)

# source() affiche le resultat sans fermer votre session RStudio.
# Seul Rscript, lance directement sur ce fichier, recoit un code de sortie.
if (controle_direct) quit(status = if (controle$ok) 0 else 1)
