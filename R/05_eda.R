# ETAPE 5 — Description et graphiques avant tout test.
summarise_noria <- function(d) {
  validate_analysis(d)
  groups <- split(d, d$workflow, drop = TRUE)
  do.call(rbind, lapply(names(groups), function(g) {
    x <- groups[[g]]$resolution_minutes
    data.frame(workflow = g, n = length(x), mean_minutes = mean(x),
               sd_minutes = sd(x), median_minutes = median(x),
               q25_minutes = unname(quantile(x, 0.25)),
               q75_minutes = unname(quantile(x, 0.75)),
               satisfaction_missing = sum(is.na(groups[[g]]$satisfaction)))
  }))
}

plot_eda <- function(d, path) {
  grDevices::pdf(path, width = 9, height = 7)
  on.exit(grDevices::dev.off())
  graphics::par(mfrow = c(2, 2), mar = c(4, 4, 3, 1))
  graphics::hist(d$resolution_minutes, main = "Noria : distribution des durees",
                 xlab = "Resolution (minutes)", col = "lightblue", breaks = 18)
  graphics::boxplot(resolution_minutes ~ workflow, data = d,
                    main = "Comparaison descriptive A/B", ylab = "Minutes", col = c("gray85", "lightblue"))
  graphics::plot(d$complexity, d$resolution_minutes,
                 col = c("gray40", "steelblue")[as.integer(d$workflow)], pch = 16,
                 xlab = "Complexite (1 a 5)", ylab = "Minutes", main = "Complexite et duree")
  # Le dénominateur des notes observées doit être visible.
  graphics::barplot(table(factor(d$satisfaction, levels = 1:5)),
                    main = paste("Satisfaction :", sum(!is.na(d$satisfaction)), "notes observees"),
                    xlab = "Note ordinale", ylab = "Tickets", col = "lightblue")
}
