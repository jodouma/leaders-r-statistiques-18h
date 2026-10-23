# ETAPE 9 — Orchestrer et exporter un résultat entièrement reproductible.
run_pipeline <- function(input = file.path("data", "noria_dirty.csv"),
                         output = "results", bootstrap = FALSE) {
  assert_project_root()
  dir.create(output, recursive = TRUE, showWarnings = FALSE)
  raw <- read_noria(input)
  cleaned <- clean_noria(raw)
  d <- cleaned$data
  objects <- language_examples(d)
  matrices <- matrix_examples()
  descriptive <- summarise_noria(d)
  inference <- compare_workflows(d)
  distributed <- mapreduce_example(d)
  keyed <- mapreduce_by_workflow(d)
  adjusted <- fit_noria(d)
  write_table(d, file.path(output, "clean.csv"))
  write_table(cleaned$audit, file.path(output, "audit.csv"))
  write_table(cleaned$exclusions, file.path(output, "exclusions.csv"))
  write_table(descriptive, file.path(output, "summary.csv"))
  write_table(inference$result, file.path(output, "welch_B_minus_A.csv"))
  write_table(distributed$partitions, file.path(output, "mapreduce_partitions.csv"))
  write_table(distributed$comparison, file.path(output, "mapreduce_comparison.csv"))
  write_table(keyed$result, file.path(output, "mapreduce_by_workflow.csv"))
  write_table(adjusted$coefficients, file.path(output, "model_coefficients.csv"))
  write_table(adjusted$diagnostics, file.path(output, "model_diagnostics.csv"))
  plot_eda(d, file.path(output, "eda.pdf"))
  plot_diagnostics(adjusted$model, file.path(output, "model_diagnostics.pdf"))
  capture.output(str(objects), str(matrices), file = file.path(output, "objects.txt"))
  capture.output(sessionInfo(), file = file.path(output, "sessionInfo.txt"))
  if (isTRUE(bootstrap)) write_table(bootstrap_difference(d), file.path(output, "bootstrap.csv"))
  message("Pipeline terminé : ", nrow(d), " tickets ; résultats dans ", output)
  invisible(list(data = d, audit = cleaned$audit, summary = descriptive,
                 inference = inference, adjusted = adjusted, mapreduce = distributed, keyed_mapreduce = keyed))
}
