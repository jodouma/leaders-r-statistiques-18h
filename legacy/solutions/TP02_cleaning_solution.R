# ARCHIVE FACULTATIVE — ancien parcours à six TP, hors tronc commun de 18 h.
# Exécuter depuis la racine : source("legacy/solutions/TP02_cleaning_solution.R")
source("scripts/00_check_setup.R", encoding = "UTF-8")
for (file in sort(list.files("R", pattern = "[.]R$", full.names = TRUE))) {
  source(file, encoding = "UTF-8")
}
# Corrigé TP02 — Audit, exclusions et exploration.
raw <- read_noria()
print(dim(raw))                              # 241 6
print(sum(duplicated(raw$ticket_id)))         # 1
print(sum(raw$workflow != trimws(raw$workflow))) # 3
print(sum(raw$team != trimws(raw$team)))      # 4
cleaned <- clean_noria(raw)
d <- cleaned$data
print(cleaned$audit, row.names = FALSE)       # 241,7,1,3,1,236,12
print(cleaned$exclusions, row.names = FALSE)  # IDs21,87,154 : manquant ;203 : invalide
print(summarise_noria(d), row.names = FALSE)
# Attendus : A n117, moyenne70.6547008547 ; B n119, moyenne66.0899159664.
# Ecarts types A17.9924720644 et B17.7379197133 ; médianes A68.2 et B66.9.
dir.create("results", showWarnings = FALSE)
plot_eda(d, "results/TP02_eda.pdf")
write_table(cleaned$audit, "results/TP02_audit.csv")
write_table(cleaned$exclusions, "results/TP02_exclusions.csv")
write_table(d, "results/TP02_clean.csv")
write_table(summarise_noria(d), "results/TP02_summary.csv")
stopifnot(nrow(d) == 236L, sum(is.na(d$satisfaction)) == 12L)
# La satisfaction reste manquante ; elle n'exclut pas un ticket de l'analyse de durée.
# Après exclusion, on ne peut plus supposer une balance exacte 120/120.
