# ETAPE 4 — Matrices, fonctions, conditions et boucles.
matrix_examples <- function() {
  # R remplit par colonnes par défaut : ce n'est pas l'ordre visuel des lignes.
  by_column <- matrix(1:6, nrow = 2)
  by_row <- matrix(1:6, nrow = 2, byrow = TRUE)
  # drop = FALSE préserve les dimensions d'une seule colonne.
  one_column <- by_row[, 1, drop = FALSE]
  totals <- numeric(nrow(by_row))
  for (i in seq_len(nrow(by_row))) {
    totals[i] <- sum(by_row[i, ])
  }
  # apply() convient ici car toutes les colonnes sont numériques.
  row_means <- apply(by_row, 1, mean)
  # Piège : un data.frame mixte est converti en matrice de caractères par apply().
  mixed <- data.frame(count = 1:2, label = c("A", "B"))
  coerced <- as.matrix(mixed)
  list(by_column = by_column, by_row = by_row, one_column = one_column,
       loop_totals = totals, row_means = row_means,
       mixed_matrix_type = typeof(coerced))
}
