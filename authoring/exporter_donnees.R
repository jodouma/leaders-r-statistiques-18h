# Reconstruction des CSV pour l'auteur ; ne modifie jamais data/.
# Rscript authoring/exporter_donnees.R depuis la racine du projet.
# Les étudiants reçoivent les CSV déjà prêts et n'ont pas besoin de ce script.
if (!file.exists('course.Rproj')) stop('Ouvrez la racine du projet.')
out <- file.path('outputs', 'reconstruction_source')
dir.create(out, recursive = TRUE, showWarnings = FALSE)
original <- data.frame(observation = seq_len(nrow(datasets::EuStockMarkets)),
                       as.matrix(datasets::EuStockMarkets))
write.csv(original, file.path(out, 'marches_source.csv'), row.names = FALSE)
# Modifications pédagogiques du 24 octobre 2026, distinctes des données réelles :
# 1. recopier exactement observation 100 ; 2. créer observation 1861, FTSE manquante.
incomplete <- original[nrow(original), ]
incomplete$observation <- nrow(original) + 1L
incomplete$FTSE <- NA_real_
training <- rbind(original, original[100, ], incomplete)
write.csv(training, file.path(out, 'marches_brut.csv'), row.names = FALSE, na = '')
cat('CSV reconstruits dans', out, '; data/ est resté intact.\n')
