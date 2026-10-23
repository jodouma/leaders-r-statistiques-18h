# Tests de contrats et propriétés, uniquement avec R de base.
# Depuis la racine : Rscript tests/run_tests.R
source("scripts/00_check_setup.R", encoding = "UTF-8")
for (file in sort(list.files("R", pattern = "[.]R$", full.names = TRUE))) source(file, encoding = "UTF-8")
expect_error <- function(expr) {
  value <- tryCatch({ force(expr); NULL }, error = function(e) e)
  if (!inherits(value, "error")) stop("Une erreur attendue n'a pas été produite.")
  invisible(TRUE)
}
near <- function(x, y, tolerance = 1e-9) isTRUE(all.equal(unname(x), unname(y), tolerance = tolerance))
raw <- read_noria()
original <- raw
cleaned <- clean_noria(raw)
d <- cleaned$data
# Les données source restent intactes ; les exclusions sont traçables par identifiant.
stopifnot(identical(raw, original), nrow(raw) == 241L, nrow(d) == 236L,
          identical(cleaned$audit$count, c(241L, 7L, 1L, 3L, 1L, 236L, 12L)),
          identical(cleaned$exclusions$ticket_id, c(21L, 87L, 154L, 203L)),
          identical(as.integer(table(d$workflow)), c(117L, 119L)),
          sum(is.na(d$satisfaction)) == 12L)
reference <- read_noria("data/noria_reference.csv")
expected <- reference[!reference$ticket_id %in% c(21, 87, 154, 203), ]
stopifnot(near(d$resolution_minutes, expected$resolution_minutes),
          identical(as.character(d$workflow), expected$workflow),
          identical(as.character(d$team), expected$team))
# L'algorithme générateur reproduit les CSV livrés, avec tolérance d'arrondi numérique.
generated <- make_noria()
stopifnot(near(generated$reference, reference), near(generated$dirty, raw))
# Un second nettoyage ne change pas les observations analysables.
stopifnot(near(clean_noria(d)$data, d))
conflict <- raw
conflict$resolution_minutes[nrow(conflict)] <- 999
expect_error(clean_noria(conflict))
bad <- raw
bad$team[1] <- "Inconnue"
expect_error(clean_noria(bad))
bad <- raw
bad$satisfaction[1] <- 6
expect_error(clean_noria(bad))
bad <- raw
bad$ticket_id[1] <- NA_integer_
expect_error(clean_noria(bad))
expect_error(clean_noria(raw[, -1]))
# Contrats des fonctions : vide, tout-NA, types incompatibles et valeurs infinies.
stopifnot(identical(safe_mean(numeric(0)), NA_real_),
          identical(safe_mean(c(NA_real_, NA_real_)), NA_real_),
          near(safe_mean(c(10, NA_real_, 30)), 20))
expect_error(safe_mean("10"))
expect_error(safe_mean(c(10, Inf)))
objects <- language_examples(d)
matrices <- matrix_examples()
stopifnot(identical(objects$selected, 30), identical(matrices$loop_totals, c(6, 15)),
          identical(dim(matrices$one_column), c(2L, 1L)),
          identical(matrices$mixed_matrix_type, "character"))
# Résultats connus et symétrie du contraste : une inversion silencieuse serait détectée.
contrast <- compare_workflows(d)
stopifnot(near(contrast$result$estimate_minutes, -4.564784888314293),
          near(summarise_noria(d)$mean_minutes, c(70.65470085470085, 66.08991596638656)),
          contrast$result$conf_low < contrast$result$estimate_minutes,
          contrast$result$estimate_minutes < contrast$result$conf_high,
          inherits(contrast$test, "htest"))
reverse <- t.test(d$resolution_minutes[d$workflow == "A"], d$resolution_minutes[d$workflow == "B"])
stopifnot(near(contrast$test$p.value, reverse$p.value),
          near(as.numeric(contrast$test$conf.int), -rev(as.numeric(reverse$conf.int))))
expect_error(compare_workflows(d[d$workflow == "A", ]))
expect_error(bootstrap_difference(d, reps = 1))
stopifnot(identical(bootstrap_difference(d, reps = 50, seed = 8),
                    bootstrap_difference(d, reps = 50, seed = 8)))
# Un exemple volontairement déséquilibré distingue pondération juste et moyenne naïve.
unequal <- list(0, rep(10, 9), c(NA_real_, NA_real_))
mapped <- lapply(unequal, map_sum_count)
reduced <- reduce_sum_count(mapped)
stopifnot(near(reduced$mean, 9), reduced$count == 10,
          near(mean(c(mean(unequal[[1]]), mean(unequal[[2]]))), 5),
          identical(reduced, reduce_sum_count(rev(mapped))),
          is.na(reduce_sum_count(list(map_sum_count(numeric(0))))$mean))
# Changer les partitions conserve la moyenne globale ; chaque ticket est compté une fois.
partitions <- split(d$resolution_minutes, rep(1:17, length.out = nrow(d)))
stopifnot(near(reduce_sum_count(lapply(partitions, map_sum_count))$mean,
              mean(d$resolution_minutes)))
expect_error(map_sum_count(c(1, Inf)))
expect_error(map_sum_count("1"))
expect_error(reduce_sum_count(list()))
expect_error(reduce_sum_count(list(c(sum = 1, count = 0))))
expect_error(reduce_sum_count(list(c(sum = 1, count = -1))))
expect_error(reduce_sum_count(list(c(sum = 1, count = 1.5))))
# Le modèle a une ligne par ticket, un contraste B-A et une décomposition cohérente.
adjusted <- fit_noria(d)
stopifnot(inherits(adjusted$model, "lm"), nobs(adjusted$model) == nrow(d),
          "workflowB" %in% adjusted$coefficients$term,
          near(adjusted$diagnostics$fitted + adjusted$diagnostics$residual,
               d$resolution_minutes), all(is.finite(adjusted$coefficients$estimate)))
# Une anomalie de domaine sur une ligne à délai manquant doit rester visible.
bad <- raw
bad$workflow[21] <- "Inconnu"
expect_error(clean_noria(bad))
bad <- raw
bad$ticket_id[1] <- 1.5
expect_error(clean_noria(bad))
# MapReduce par clé : même couverture malgré d'autres frontières de partitions.
keyed <- mapreduce_by_workflow(d)
stopifnot(identical(keyed$result$workflow, c("A", "B")),
          near(keyed$result$sum, c(8266.6, 7864.7)),
          all(keyed$result$count == c(117, 119)),
          near(keyed$result$mean_minutes, c(70.65470085470085, 66.08991596638656)),
          near(keyed$result, mapreduce_by_workflow(d, rep(1:17, length.out = nrow(d)))$result))
empty_map <- map_by_workflow(d[FALSE, ])
stopifnot(nrow(empty_map) == 0L,
          near(reduce_by_workflow(c(keyed$mapped, list(vide = empty_map))), keyed$result))
a_map <- map_by_workflow(d[d$workflow == "A", ])
stopifnot(nrow(a_map) == 1L, reduce_by_workflow(list(a_map))$count == 117)
expect_error(reduce_by_workflow(c(keyed$mapped, keyed$mapped[1])))
expect_error(mapreduce_by_workflow(d, rep(NA_character_, nrow(d))))
expect_error(map_by_workflow(data.frame(workflow = "C", resolution_minutes = 4)))
expect_error(reduce_by_workflow(list(data.frame(workflow = "A", sum = factor("9"), count = 1))))
cat("Tous les tests de contrats et de propriétés ont réussi.\n")
