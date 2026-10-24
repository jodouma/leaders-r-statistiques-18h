# Reconstruction des CSV pour l'auteur ; ne modifie jamais data/.
# Rscript authoring/exporter_donnees.R depuis la racine du projet.
# Les étudiants reçoivent les CSV déjà prêts et n'ont pas besoin de ce script.
if (!file.exists('course.Rproj')) stop('Ouvrez la racine du projet.')
out <- file.path('outputs', 'reconstruction_source')
dir.create(out, recursive = TRUE, showWarnings = FALSE)
# Une connexion binaire conserve LF sous Windows aussi : mêmes octets sur les trois OS.
# Les CSV du cours sont en ASCII ; aucun transcodage du texte n'est nécessaire.
# Voir la documentation officielle de write.table, rubrique Details.
write_csv_lf <- function(table, path) {
  connection <- file(path, open = "wb")
  on.exit(close(connection), add = TRUE)
  write.csv(table, connection, row.names = FALSE, na = "", eol = "\n")
}
original <- data.frame(observation = seq_len(nrow(datasets::EuStockMarkets)),
                       as.matrix(datasets::EuStockMarkets))
write_csv_lf(original, file.path(out, 'marches_source.csv'))
# Modifications pédagogiques du 24 octobre 2026, distinctes des données réelles :
# 1. recopier exactement observation 100 ; 2. créer observation 1861, FTSE manquante.
incomplete <- original[nrow(original), ]
incomplete$observation <- nrow(original) + 1L
incomplete$FTSE <- NA_real_
training <- rbind(original, original[100, ], incomplete)
write_csv_lf(training, file.path(out, 'marches_brut.csv'))
cat('CSV reconstruits dans', out, '; data/ est resté intact.\n')
