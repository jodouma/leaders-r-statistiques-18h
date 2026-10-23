# Exemple indépendant : trois phrases sur une exposition fictive, pas sur Noria.
# Exécuter depuis le projet ; R de base suffit. Le résultat tient sur UNE page.
ecrire_note_pdf <- function(lignes, chemin) {
  if (!is.character(lignes) || length(lignes) == 0 || anyNA(lignes) ||
      any(nchar(trimws(lignes)) == 0)) {
    stop("Fournir des phrases non vides, sans NA.")
  }
  # strwrap coupe les phrases en lignes courtes ; une ligne vide sépare les phrases.
  texte <- unlist(lapply(lignes, function(phrase) c(strwrap(phrase, width = 78), "")))
  # La garde précède pdf() : un texte trop long est refusé, jamais coupé en silence.
  if (length(texte) > 40 || any(nchar(texte) > 78)) {
    stop("Note trop longue pour une page : raccourcir les phrases ou les mots longs.")
  }
  pdf(chemin, width = 8.27, height = 11.69)
  on.exit(dev.off(), add = TRUE) # Fermer aussi le fichier si le tracé échoue.
  par(mar = c(1, 1, 1, 1))
  plot.new()                    # Une page vide devient une surface de texte.
  text(0.03, 0.97, paste(texte, collapse = "\n"), adj = c(0, 1), cex = 0.85)
  invisible(chemin)
}
note_mini <- c(
  "Dans cet exemple fictif, trois visites d'une exposition durent 10, 20 et 30 minutes.",
  "La durée moyenne est 20 minutes ; ce résumé ne décrit pas toutes les visites possibles.",
  "Avant de modifier les horaires, recueillir davantage d'observations et vérifier leur représentativité.")
dir.create("results", showWarnings = FALSE)
ecrire_note_pdf(note_mini, "results/mini_note.pdf")
# Transfert TP04 : recopier la fonction, puis l'appeler avec vos propres phrases :
# ecrire_note_pdf(recommandation4, "results/TP04_recommandation.pdf")
# Si la garde refuse la note, raccourcir le texte plutôt que réduire la police.
