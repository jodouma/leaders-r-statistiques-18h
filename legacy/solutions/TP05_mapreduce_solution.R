# ARCHIVE FACULTATIVE — ancien parcours à six TP, hors tronc commun de 18 h.
# Exécuter depuis la racine : source("legacy/solutions/TP05_mapreduce_solution.R")
source("scripts/00_check_setup.R", encoding = "UTF-8")
for (file in sort(list.files("R", pattern = "[.]R$", full.names = TRUE))) {
  source(file, encoding = "UTF-8")
}
# Corrigé TP05 — La pondération provient des effectifs observés.
d <- clean_noria(read_noria())$data
lot <- c(rep("petit", 7), rep("moyen", 53), rep("grand", 176))
partitions <- split(d$resolution_minutes, lot)
mapped <- lapply(partitions, map_sum_count)
reduced <- reduce_sum_count(mapped)
print(mapped)                              # grand12119.5/176 ; moyen3531.2/53 ; petit480.6/7
print(reduced)                              # sum16131.3 ; count236 ; mean68.3529661017
print(mapreduce_example(d)$comparison, row.names = FALSE)
# Moyenne non pondérée des moyennes : 68.0481178020, au lieu de 68.3529661017.
# Le calcul correct somme les sommes et les effectifs, avant UNE division finale.
trap <- list(rep(10, 2), rep(20, 8))
print(mean(vapply(trap, mean, numeric(1))))   # 15, incorrect pour la moyenne des 10 valeurs
print(reduce_sum_count(lapply(trap, map_sum_count))$mean) # 18
with_empty <- c(mapped, list(map_sum_count(c(NA_real_, NA_real_))))
stopifnot(isTRUE(all.equal(reduced, reduce_sum_count(with_empty))),
          isTRUE(all.equal(reduced$mean, mean(d$resolution_minutes))))
# Ajouter une partition entièrement absente apporte somme0/effectif0, pas un NaN à moyenner.

# Noyau PAR WORKFLOW : le map conserve une clé, pas seulement un total global.
ticket_partitions <- split(d, lot)
ids <- unlist(lapply(ticket_partitions, function(part) part$ticket_id), use.names = FALSE)
stopifnot(length(ids) == nrow(d), !anyDuplicated(ids), setequal(ids, d$ticket_id))
keyed_map <- lapply(ticket_partitions, map_by_workflow)
print(keyed_map)                             # uniquement clé/somme/effectif par lot
keyed_result <- reduce_by_workflow(keyed_map) # contient le shuffle par clé
print(keyed_result, row.names = FALSE)
# Attendus A : somme8266.6,n117,moyenne70.6547008547 ; B :7864.7,119,66.0899159664.
central_groups <- split(d$resolution_minutes, d$workflow)
central_means <- vapply(central_groups, mean, numeric(1))
central_sums <- vapply(central_groups, sum, numeric(1))
central_counts <- vapply(central_groups, length, integer(1))
comparison <- data.frame(workflow = keyed_result$workflow, central = unname(central_means),
                          mapped_reduced = keyed_result$mean_minutes,
                          difference = keyed_result$mean_minutes - unname(central_means))
print(comparison, row.names = FALSE)          # écarts nuls à l'arrondi numérique près
stopifnot(isTRUE(all.equal(keyed_result$sum, unname(central_sums), tolerance = 1e-10)),
          all(keyed_result$count == unname(central_counts)),
          all(abs(comparison$difference) < 1e-10))
alternative <- mapreduce_by_workflow(d, rep(1:17, length.out = nrow(d)))$result
stopifnot(isTRUE(all.equal(keyed_result, alternative, tolerance = 1e-10)))
# Défis : les résumés peuvent omettre une clé ; un lot vide n'ajoute aucun effectif.
empty <- map_by_workflow(d[FALSE, ])
only_a <- map_by_workflow(d[d$workflow == "A", ])
stopifnot(nrow(empty) == 0L, nrow(only_a) == 1L)
stopifnot(isTRUE(all.equal(reduce_by_workflow(c(keyed_map, list(vide = empty))), keyed_result)))
# Détection locale d'un même nom de lot livré deux fois : erreur intentionnelle.
print(try(reduce_by_workflow(c(keyed_map, keyed_map[1])), silent = TRUE))
# Aucun shuffle réseau ni ordonnanceur ni mécanisme de reprise n'a été exécuté.
