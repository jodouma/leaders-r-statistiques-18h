# Outils communs fournis : les scripts les chargent automatiquement.
# Les fonctions regroupent une tâche réutilisée ; aucune bibliothèque à installer.
market_names <- c("DAX", "SMI", "CAC", "FTSE")

# Les petits contrôles de paramètres évitent d'alourdir les premiers calculs.
validate_capital <- function(capital) {
  if (length(capital) != 1 || !is.finite(capital) || capital <= 0)
    stop("Choisissez un capital positif.", call. = FALSE)
  invisible(TRUE)
}
validate_rate <- function(rate) {
  if (length(rate) != 1 || !is.finite(rate) || rate < -1)
    stop("Le taux doit être fini et au moins égal à -1.", call. = FALSE)
  invisible(TRUE)
}

prepare_output <- function(step) {
  path <- file.path("outputs", step)
  dir.create(path, recursive = TRUE, showWarnings = FALSE)
  path
}

read_markets <- function(path = "data/marches_brut.csv") {
  if (!file.exists(path)) stop("CSV introuvable : ouvrez course.Rproj puis recommencez.", call. = FALSE)
  data <- read.csv(path, stringsAsFactors = FALSE, check.names = FALSE)
  expected <- c("observation", market_names)
  if (!identical(names(data), expected)) stop("Colonnes attendues : observation, DAX, SMI, CAC, FTSE.", call. = FALSE)
  if (nrow(data) < 3L || !all(vapply(data, is.numeric, logical(1))))
    stop("Le CSV doit contenir au moins 3 lignes et des colonnes numériques.", call. = FALSE)
  if (anyNA(data$observation) || any(!is.finite(data$observation)) ||
      any(data$observation <= 0 | data$observation != floor(data$observation)))
    stop("Chaque observation doit être un entier positif renseigné.", call. = FALSE)
  prices <- as.matrix(data[market_names])
  if (any(!is.na(prices) & (!is.finite(prices) | prices <= 0)))
    stop("Les niveaux d'indices renseignés doivent être positifs et finis.", call. = FALSE)
  data
}

clean_markets <- function(raw) {
  # duplicated repère une répétition exacte de toutes les colonnes.
  repeated <- duplicated(raw)
  unique_data <- raw[!repeated, , drop = FALSE]
  if (anyDuplicated(unique_data$observation))
    stop("Deux lignes différentes portent la même observation : vérifiez le CSV.", call. = FALSE)
  complete <- complete.cases(unique_data)
  prices <- unique_data[complete, , drop = FALSE]
  prices <- prices[order(prices$observation), , drop = FALSE]
  rownames(prices) <- NULL
  if (nrow(prices) < 3L) stop("Il faut au moins 3 observations complètes.", call. = FALSE)
  list(prices = prices, quarantine = unique_data[!complete, , drop = FALSE],
       duplicates = raw[repeated, , drop = FALSE])
}

validate_spacing <- function(prices) {
  # Ne pas confondre une variation sur plusieurs observations avec une seule.
  if (any(diff(prices$observation) != 1))
    stop(paste("Une observation manque dans la série complète.",
               "Vérifiez les lignes en quarantaine avant de calculer les rendements."),
         call. = FALSE)
  invisible(TRUE)
}

make_returns <- function(prices) {
  validate_spacing(prices)
  levels <- as.matrix(prices[market_names])
  # Deux lignes voisines : (nouveau - ancien) / ancien.
  values <- levels[-1, , drop = FALSE] / levels[-nrow(levels), , drop = FALSE] - 1
  data.frame(observation = prices$observation[-1], values, check.names = FALSE)
}

basket_returns <- function(returns, cac_weight = 0.60) {
  if (length(cac_weight) != 1L || !is.finite(cac_weight) || cac_weight < 0 || cac_weight > 1)
    stop("Le poids CAC doit être compris entre 0 et 1.", call. = FALSE)
  cac_weight * returns$CAC + (1 - cac_weight) * returns$DAX
}

risk_summary <- function(returns, capital = 10000, confidence = 0.95) {
  if (length(capital) != 1L || !is.finite(capital) || capital <= 0 ||
      length(confidence) != 1L || !is.finite(confidence) || confidence <= 0 || confidence >= 1)
    stop("Capital positif et confiance strictement entre 0 et 1 attendus.", call. = FALSE)
  # On inclut le capital initial : la première baisse compte dans le drawdown.
  wealth <- capital * cumprod(c(1, 1 + returns))
  drawdown <- wealth / cummax(wealth) - 1
  data.frame(confidence = confidence,
             historical_VaR_UM = as.numeric(quantile(-returns, confidence, type = 7)) * capital,
             maximum_drawdown = min(drawdown), final_capital_UM = tail(wealth, 1))
}

save_table <- function(data, folder, name) {
  write.csv(data, file.path(folder, name), row.names = FALSE, na = "")
}

save_plot <- function(folder, name, drawing) {
  # Le même dessin est sauvegardé et affiché dans Plots si RStudio est ouvert.
  code <- substitute(drawing)
  png(file.path(folder, name), width = 1400, height = 900, res = 140)
  tryCatch(eval(code, parent.frame()), finally = dev.off())
  if (interactive()) eval(code, parent.frame())
  cat("Graphique enregistré :", file.path(folder, name), "\n")
}

self_check <- function(condition, message) {
  verdict <- if (isTRUE(condition)) "Observation cohérente" else "À examiner"
  cat("Auto-vérification —", verdict, ":", message, "\n")
  # Aucun quit() : la session et les objets restent disponibles.
  invisible(condition)
}
