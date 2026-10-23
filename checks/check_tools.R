# Infrastructure des controles uniquement. Aucun code de solution n'est charge.
# Les missions et les exemples n'ont pas besoin de ce fichier.
eq_num <- function(actual, expected) {
  is.numeric(actual) && length(actual) == length(expected) &&
    !anyNA(actual) && isTRUE(all.equal(as.numeric(actual), as.numeric(expected),
                                     tolerance = 1e-8, check.attributes = FALSE))
}
table_same <- function(actual, expected, key = NULL) {
  if (!is.data.frame(actual) || nrow(actual) != nrow(expected) ||
      !all(names(expected) %in% names(actual))) return(FALSE)
  actual <- actual[, names(expected), drop = FALSE]
  if (!is.null(key)) {
    actual <- actual[order(as.character(actual[[key]])), , drop = FALSE]
    expected <- expected[order(as.character(expected[[key]])), , drop = FALSE]
  }
  for (column in names(expected)) {
    a <- actual[[column]]; b <- expected[[column]]
    if (!identical(is.na(a), is.na(b))) return(FALSE)
    keep <- !is.na(b)
    if (!any(keep)) next
    if (is.numeric(b)) {
      if (!eq_num(a[keep], b[keep])) return(FALSE)
    } else if (!identical(as.character(a[keep]), as.character(b[keep]))) return(FALSE)
  }
  TRUE
}
read_output <- function(path) {
  if (!file.exists(path)) return(NULL)
  tryCatch(read.csv(path, stringsAsFactors = FALSE), error = function(e) NULL)
}
valid_png <- function(path) {
  if (!file.exists(path) || file.info(path)$size < 500) return(FALSE)
  con <- file(path, "rb"); on.exit(close(con))
  identical(readBin(con, "raw", 8), as.raw(c(137, 80, 78, 71, 13, 10, 26, 10)))
}
expected_products <- function() {
  data.frame(produit = c("Cafe", "The", "Sandwich"),
             chiffre_affaires = c(30, 30, 40), cout_total = c(10, 12, 15),
             marge = c(20, 18, 25))
}
expected_days <- function() {
  data.frame(date = paste0("2026-10-0", 5:8), chiffre_affaires = c(19, 27, 33, 21),
             cout_total = c(7, 10, 12, 8), marge = c(12, 17, 21, 13))
}
expected_summary <- function(second = FALSE) {
  if (second) data.frame(chiffre_affaires=48, cout_total=18, marge=30,
                        quantite=9, n_commandes=6)
  else data.frame(chiffre_affaires=100, cout_total=37, marge=63,
                  quantite=21, n_commandes=12)
}
run_check <- function(stem, verify, use_cli_args = FALSE) {
  if (!file.exists("data/orders_raw.csv")) {
    cat("Placez le terminal a la racine du dossier du cours, puis recommencez.\n")
    return(invisible(list(ok=FALSE, results=list(), error="Fichier ou dossier introuvable")))
  }
  args <- if (isTRUE(use_cli_args)) commandArgs(trailingOnly = TRUE) else character()
  target <- if (length(args)) args[1] else file.path("missions", paste0(stem, ".R"))
  if (!file.exists(target)) {
    cat("Script introuvable :", target, "\n")
    return(invisible(list(ok=FALSE, results=list(), error="Fichier ou dossier introuvable")))
  }
  target <- normalizePath(target, mustWork = TRUE)
  origin <- getwd()
  sandbox <- tempfile("noria-controle-")
  dir.create(sandbox)
  previous_devices <- grDevices::dev.list()
  on.exit({
    new_devices <- setdiff(grDevices::dev.list(), previous_devices)
    for (device in new_devices) try(grDevices::dev.off(device), silent=TRUE)
    setwd(origin)
    unlink(sandbox, recursive = TRUE)
  }, add = TRUE)
  file.copy("data", sandbox, recursive = TRUE)
  dir.create(file.path(sandbox, "outputs"))
  # Le fichier de mission 4 est un vrai input des missions 5 a 7.
  # Copier uniquement cet input existant, jamais les reponses de la mission en cours.
  upstream <- file.path(origin, "outputs", "04_commandes_propres.csv")
  if (stem %in% c("05_analyser", "06_visualiser", "07_decider") && file.exists(upstream)) {
    file.copy(upstream, file.path(sandbox, "outputs", "04_commandes_propres.csv"))
  }
  setwd(sandbox)
  # Les anciens resultats et objets de Console ne sont pas reutilises.
  student <- new.env(parent = parent.env(globalenv()))
  error <- tryCatch({sys.source(target, envir = student); NULL},
                    error = function(e) conditionMessage(e))
  if (!is.null(error)) {
    cat("A reprendre : le script ne termine pas :", error, "\n")
    return(invisible(list(ok=FALSE, results=list(), error=error)))
  }
  results <- list()
  check <- function(label, ok) {
    pass <- tryCatch(isTRUE(ok), error = function(e) FALSE)
    results[[length(results) + 1L]] <<- list(label=label, pass=pass)
    cat(if (pass) "OK :" else "A reprendre :", label, "\n")
  }
  # Objet absent = NULL, pour donner une explication au lieu d'une erreur obscure.
  get_student <- function(name) {
    if (exists(name, envir=student, inherits=FALSE)) get(name, envir=student) else NULL
  }
  verify(get_student, check)
  ok <- length(results) > 0L && all(vapply(results, function(x) x$pass, logical(1)))
  cat(if (ok) "Controle : OK\n" else "Controle : a reprendre\n")
  if (stem == "06_visualiser") cat("Relire aussi titres, labels et axe TND dans les deux images.\n")
  if (stem == "07_decider") cat("Relire aussi le sens et la prudence du texte de decision.\n")
  invisible(list(ok=ok, results=results, error=NULL))
}
