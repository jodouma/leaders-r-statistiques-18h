# ETAPE 7 — MapReduce local : des statistiques suffisantes, sans infrastructure.
map_sum_count <- function(x) {
  if (!is.numeric(x) || any(!is.finite(x) & !is.na(x))) stop("Vecteur numérique fini ou NA requis.")
  c(sum = sum(x, na.rm = TRUE), count = sum(!is.na(x)))
}
reduce_sum_count <- function(mapped) {
  if (!is.list(mapped) || length(mapped) == 0L) stop("Liste non vide requise.")
  valid <- vapply(mapped, function(x) {
    is.numeric(x) && identical(names(x), c("sum", "count")) && length(x) == 2L &&
      all(is.finite(x)) && x[["count"]] >= 0 && x[["count"]] == floor(x[["count"]]) &&
      (x[["count"]] > 0 || x[["sum"]] == 0)
  }, logical(1))
  if (!all(valid)) stop("Résumé sum/count invalide.")
  total <- Reduce(`+`, mapped)
  average <- if (total[["count"]] == 0) NA_real_ else total[["sum"]] / total[["count"]]
  list(sum = unname(total[["sum"]]), count = unname(total[["count"]]), mean = average)
}
mapreduce_example <- function(d) {
  # Les lots volontairement inégaux rendent visible l'erreur moyenne(des moyennes).
  n <- nrow(d)
  lot <- c(rep("petit", 7), rep("moyen", 53), rep("grand", n - 60))
  partitions <- split(d$resolution_minutes, lot)
  mapped <- lapply(partitions, map_sum_count)
  reduced <- reduce_sum_count(mapped)
  partial <- data.frame(partition = names(mapped),
                         sum = vapply(mapped, function(x) x[["sum"]], numeric(1)),
                         count = vapply(mapped, function(x) x[["count"]], numeric(1)))
  partial$mean <- partial$sum / partial$count
  list(partitions = partial,
       comparison = data.frame(method = c("direct", "sum_count", "mean_of_means_incorrect"),
                               mean_minutes = c(mean(d$resolution_minutes), reduced$mean,
                                                mean(partial$mean))))
}

# Variante PAR CLE workflow : map émet des résumés, shuffle les regroupe,
# reduce les combine. Il s'agit d'un seul processus local, sans worker Hadoop.
map_by_workflow <- function(partition) {
  needed <- c("workflow", "resolution_minutes")
  if (!is.data.frame(partition) || !all(needed %in% names(partition))) {
    stop("Partition attendue : workflow et resolution_minutes.")
  }
  if (anyNA(partition$workflow) || any(!as.character(partition$workflow) %in% c("A", "B"))) {
    stop("Clé workflow inconnue.")
  }
  if (!is.numeric(partition$resolution_minutes)) stop("Durées numériques requises.")
  if (nrow(partition) == 0L) {
    return(data.frame(workflow = character(), sum = numeric(), count = numeric()))
  }
  groups <- split(partition$resolution_minutes, partition$workflow, drop = TRUE)
  do.call(rbind, lapply(names(groups), function(key) {
    stats <- map_sum_count(groups[[key]])
    data.frame(workflow = key, sum = unname(stats[["sum"]]), count = unname(stats[["count"]]))
  }))
}

reduce_by_workflow <- function(mapped) {
  if (!is.list(mapped) || length(mapped) == 0L) stop("Liste de partitions requise.")
  # Des identifiants de lots stables permettent de détecter une répétition locale.
  # Cela ne remplace pas les garanties de livraison d'un système distribué.
  if (!is.null(names(mapped)) &&
      (anyNA(names(mapped)) || any(!nzchar(names(mapped))) || anyDuplicated(names(mapped)))) {
    stop("Identifiants de partitions uniques et non vides requis.")
  }
  for (part in mapped) {
    if (!is.data.frame(part) || !identical(names(part), c("workflow", "sum", "count")) ||
        anyNA(part$workflow) || any(!part$workflow %in% c("A", "B")) ||
        anyDuplicated(part$workflow) || !is.numeric(part$sum) || !is.numeric(part$count)) {
      stop("Emission par clé invalide.")
    }
    # Réutiliser le contrat somme/effectif pour chaque résumé émis.
    for (i in seq_len(nrow(part))) {
      reduce_sum_count(list(c(sum = part$sum[i], count = part$count[i])))
    }
  }
  emitted <- do.call(rbind, mapped)
  if (nrow(emitted) == 0L) {
    return(data.frame(workflow = character(), sum = numeric(), count = numeric(), mean_minutes = numeric()))
  }
  # SHUFFLE : seules les lignes de résumés sont regroupées par clé.
  shuffled <- split(emitted, emitted$workflow, drop = TRUE)
  do.call(rbind, lapply(names(shuffled), function(key) {
    group <- shuffled[[key]]
    total <- reduce_sum_count(lapply(seq_len(nrow(group)), function(i) {
      c(sum = group$sum[i], count = group$count[i])
    }))
    data.frame(workflow = key, sum = total$sum, count = total$count, mean_minutes = total$mean)
  }))
}

mapreduce_by_workflow <- function(d, partition_id = NULL) {
  validate_analysis(d)
  if (is.null(partition_id)) {
    if (nrow(d) < 61L) stop("L'exemple 7/53/reste attend au moins 61 tickets.")
    partition_id <- c(rep("petit", 7), rep("moyen", 53), rep("grand", nrow(d) - 60))
  }
  if (length(partition_id) != nrow(d) || anyNA(partition_id) || any(!nzchar(as.character(partition_id)))) {
    stop("Une partition non vide doit être désignée pour chaque ticket.")
  }
  partitions <- split(d, partition_id, drop = TRUE)
  # Vérifier la couverture avant de ne garder que des résumés agrégés.
  ids <- unlist(lapply(partitions, function(part) part$ticket_id), use.names = FALSE)
  stopifnot(!anyDuplicated(ids), setequal(ids, d$ticket_id))
  mapped <- lapply(partitions, map_by_workflow)
  list(mapped = mapped, result = reduce_by_workflow(mapped))
}
