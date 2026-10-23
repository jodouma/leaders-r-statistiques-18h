# Régénération facultative : Rscript scripts/02_generate_data.R
# Les deux CSV sont déjà fournis ; cette commande les remplace à l'identique.
source("R/00_utils.R", encoding = "UTF-8")
assert_project_root()
source("R/01_data.R", encoding = "UTF-8")
generated <- make_noria()
write_table(generated$reference, "data/noria_reference.csv")
write_table(generated$dirty, "data/noria_dirty.csv")
cat("240 lignes de référence ; 241 lignes brutes.\n")
