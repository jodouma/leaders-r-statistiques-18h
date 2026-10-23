# ETAPE 8 — Modèle ajusté et diagnostic des résidus.
fit_noria <- function(d) {
  validate_analysis(d)
  d$workflow <- factor(d$workflow, levels = c("A", "B"))
  d$team <- factor(d$team, levels = c("Atlas", "Boreal", "Cedre"))
  model <- stats::lm(resolution_minutes ~ workflow + complexity + team, data = d)
  coefs <- summary(model)$coefficients
  intervals <- stats::confint(model)
  coefficients <- data.frame(term = rownames(coefs), estimate = coefs[, 1],
                              std_error = coefs[, 2], t = coefs[, 3], p_value = coefs[, 4],
                              conf_low = intervals[, 1], conf_high = intervals[, 2],
                              row.names = NULL)
  diagnostics <- data.frame(ticket_id = d$ticket_id, fitted = stats::fitted(model),
                            residual = stats::residuals(model),
                            standardized_residual = stats::rstandard(model),
                            cooks_distance = stats::cooks.distance(model))
  list(model = model, coefficients = coefficients, diagnostics = diagnostics)
}
plot_diagnostics <- function(model, path) {
  grDevices::pdf(path, width = 9, height = 7)
  on.exit(grDevices::dev.off())
  graphics::par(mfrow = c(2, 2))
  graphics::plot(model, which = c(1, 2, 3, 5))
}
# Interprétation : workflowB est l'écart ajusté B-A sous un effet additif.
# Inspecter linéarité, variance, forme des résidus et points influents.
# Les p-valeurs et IC usuels supposent le modèle d'erreur adapté ; les graphiques
# ne prouvent pas l'indépendance. Les exclusions après allocation peuvent biaiser
# l'estimation ; ici les mécanismes sont artificiels et connus. Aucune conclusion
# commerciale réelle n'est justifiée par ces données simulées.
