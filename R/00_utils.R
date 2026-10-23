# ETAPE 0 — Petites fonctions communes, sans paquet externe.
# Exécuter les scripts depuis la racine du projet ; aucun setwd() caché.
assert_project_root <- function() {
  if (!file.exists("course.Rproj") || !dir.exists("data")) {
    stop("Ouvrir course.Rproj, puis exécuter depuis la racine du projet.")
  }
  invisible(TRUE)
}

# Un résultat absent est plus informatif qu'un NaN silencieux.
safe_mean <- function(x) {
  if (!is.numeric(x)) stop("safe_mean attend un vecteur numérique.")
  if (any(!is.finite(x) & !is.na(x))) stop("Valeurs infinies interdites.")
  if (all(is.na(x))) return(NA_real_)
  mean(x, na.rm = TRUE)
}

# Vérifier l'ordre des groupes évite une inversion du contraste.
validate_analysis <- function(d) {
  needed <- c("ticket_id", "workflow", "resolution_minutes", "complexity",
              "satisfaction", "team")
  if (!is.data.frame(d) || !all(needed %in% names(d))) stop("Schéma incomplet.")
  if (nrow(d) == 0L || !is.numeric(d$ticket_id) || anyDuplicated(d$ticket_id) || anyNA(d$ticket_id) ||
      any(!is.finite(d$ticket_id)) || any(d$ticket_id <= 0 | d$ticket_id != floor(d$ticket_id))) {
    stop("Identifiants uniques et non manquants requis.")
  }
  if (!is.numeric(d$resolution_minutes) || anyNA(d$resolution_minutes) ||
      any(!is.finite(d$resolution_minutes)) || any(d$resolution_minutes <= 0)) {
    stop("Les durées doivent être finies, strictement positives et observées.")
  }
  if (anyNA(d$workflow) || !setequal(unique(as.character(d$workflow)), c("A", "B"))) {
    stop("Les deux workflows A et B sont requis.")
  }
  if (any(table(d$workflow) < 2)) stop("Au moins deux tickets par groupe.")
  if (!is.numeric(d$complexity) || anyNA(d$complexity) ||
      any(!is.finite(d$complexity)) || any(!d$complexity %in% 1:5)) {
    stop("Complexité attendue : entier numérique de 1 à 5.")
  }
  if (anyNA(d$team) || any(!as.character(d$team) %in% c("Atlas", "Boreal", "Cedre"))) {
    stop("Equipe inconnue.")
  }
  if (!is.numeric(d$satisfaction) ||
      any(!is.na(d$satisfaction) & !d$satisfaction %in% 1:5)) {
    stop("Satisfaction attendue : 1 à 5 ou NA.")
  }
  invisible(TRUE)
}

# Une fonction exporte toujours un tableau sans les noms de lignes implicites.
write_table <- function(x, path) {
  utils::write.csv(x, path, row.names = FALSE, na = "", fileEncoding = "UTF-8")
}
