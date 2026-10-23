# ETAPE 3 — Objets, attributs, vecteurs et valeurs manquantes.
language_examples <- function(d) {
  x <- c(10, NA_real_, 30)
  # x[x > 15] garde un NA : le masque contient lui-même une valeur inconnue.
  mask_with_na <- x > 15
  selected <- x[!is.na(x) & x > 15]
  names(x) <- c("premier", "absent", "dernier")
  m <- matrix(1:6, nrow = 2)
  # Une liste garde des objets de types différents ; str() révèle sa structure.
  objects <- list(vector = x, matrix = m, table = d,
                  grouped = table(d$workflow))
  # ordered() exprime l'ordre des notes ; as.numeric(factor) rend les codes internes.
  ordinal <- ordered(d$satisfaction, levels = 1:5)
  list(mask_with_na = mask_with_na, selected = selected,
       safe_average = safe_mean(x), object_classes = lapply(objects, class),
       vector_attributes = attributes(x), matrix_attributes = attributes(m),
       satisfaction = ordinal)
}
