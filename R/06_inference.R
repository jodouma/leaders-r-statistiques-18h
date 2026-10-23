# ETAPE 6 — Welch : contraste explicitement défini B moins A, en minutes.
compare_workflows <- function(d, conf_level = 0.95) {
  validate_analysis(d)
  a <- d$resolution_minutes[d$workflow == "A"]
  b <- d$resolution_minutes[d$workflow == "B"]
  # t.test(x = B, y = A) calcule directement B-A ; l'ordre de la formule peut piéger.
  test <- stats::t.test(x = b, y = a, var.equal = FALSE, conf.level = conf_level)
  result <- data.frame(contrast = "B - A", estimate_minutes = mean(b) - mean(a),
                       conf_low = unname(test$conf.int[1]), conf_high = unname(test$conf.int[2]),
                       t = unname(test$statistic), df = unname(test$parameter), p_value = test$p.value,
                       conf_level = conf_level)
  # htest est une liste S3 : accès nommé, jamais une capture d'écran du résultat.
  list(test = test, result = result)
}

bootstrap_difference <- function(d, reps = 2000L, seed = 742) {
  validate_analysis(d)
  if (length(reps) != 1L || is.na(reps) || !is.finite(reps) || reps < 2 || reps != floor(reps)) {
    stop("reps doit être un entier >= 2.")
  }
  set.seed(seed)
  a <- d$resolution_minutes[d$workflow == "A"]
  b <- d$resolution_minutes[d$workflow == "B"]
  draws <- replicate(reps, mean(sample(b, length(b), replace = TRUE)) -
                            mean(sample(a, length(a), replace = TRUE)))
  # Extension : intervalle percentile ; il ne corrige pas un biais de sélection.
  data.frame(contrast = "B - A", reps = reps,
             conf_low = unname(quantile(draws, 0.025)),
             conf_high = unname(quantile(draws, 0.975)))
}
