# ETAPE 2 — Nettoyer avec règles nommées et audit des pertes.
clean_noria <- function(raw) {
  needed <- c("ticket_id", "workflow", "resolution_minutes", "complexity", "satisfaction", "team")
  if (!is.data.frame(raw) || !identical(names(raw), needed)) stop("Colonnes ou ordre inattendus.")
  if (!is.numeric(raw$ticket_id) || anyNA(raw$ticket_id) ||
      any(!is.finite(raw$ticket_id)) || any(raw$ticket_id <= 0 | raw$ticket_id != floor(raw$ticket_id))) {
    stop("Identifiant entier strictement positif requis.")
  }
  if (!is.numeric(raw$resolution_minutes)) stop("Durées numériques requises.")
  d <- raw
  trimmed <- sum(d$workflow != trimws(d$workflow), na.rm = TRUE) +
             sum(d$team != trimws(d$team), na.rm = TRUE)
  d$workflow <- trimws(d$workflow)
  d$team <- trimws(d$team)
  # Contrôler aussi les lignes qui seront exclues pour durée absente : une autre
  # anomalie ne doit pas disparaître silencieusement avec cette exclusion.
  if (anyNA(d$workflow) || any(!d$workflow %in% c("A", "B")) ||
      anyNA(d$team) || any(!d$team %in% c("Atlas", "Boreal", "Cedre"))) {
    stop("Libellé workflow ou équipe inconnu.")
  }
  if (!is.numeric(d$complexity) || anyNA(d$complexity) || any(!d$complexity %in% 1:5)) {
    stop("Complexité attendue : entier numérique de 1 à 5.")
  }
  if (!is.numeric(d$satisfaction) || any(!is.na(d$satisfaction) & !d$satisfaction %in% 1:5)) {
    stop("Satisfaction attendue : 1 à 5 ou NA.")
  }
  # Le premier enregistrement est conservé ; un conflit de valeurs exige une enquête.
  duplicated_rows <- duplicated(d$ticket_id)
  if (any(duplicated_rows)) {
    for (i in which(duplicated_rows)) {
      j <- match(d$ticket_id[i], d$ticket_id)
      if (!isTRUE(all.equal(d[i, ], d[j, ], check.attributes = FALSE))) {
        stop("Doublon conflictuel : ne pas choisir arbitrairement une version.")
      }
    }
  }
  duplicate_count <- sum(duplicated_rows)
  d <- d[!duplicated_rows, , drop = FALSE]
  missing <- is.na(d$resolution_minutes)
  impossible <- !missing & (!is.finite(d$resolution_minutes) | d$resolution_minutes <= 0)
  exclusions <- data.frame(ticket_id = d$ticket_id[missing | impossible],
                           reason = ifelse(missing[missing | impossible],
                                           "missing_outcome", "nonpositive_or_nonfinite_outcome"))
  missing_count <- sum(missing)
  impossible_count <- sum(impossible)
  # Pas d'imputation de durée : elle modifierait artificiellement la variance.
  d <- d[!missing & !impossible, , drop = FALSE]
  d$workflow <- factor(d$workflow, levels = c("A", "B"))
  d$team <- factor(d$team, levels = c("Atlas", "Boreal", "Cedre"))
  rownames(d) <- NULL
  validate_analysis(d)
  audit <- data.frame(metric = c("raw_rows", "trimmed_label_cells", "duplicate_rows_removed",
                                 "missing_outcomes_removed", "invalid_outcomes_removed",
                                 "clean_rows", "satisfaction_missing_retained"),
                       count = c(nrow(raw), trimmed, duplicate_count, missing_count,
                                 impossible_count, nrow(d), sum(is.na(d$satisfaction))))
  list(data = d, audit = audit, exclusions = exclusions)
}
