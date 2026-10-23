# Exécuter depuis la racine : source("labs/TP05_mapreduce.R")
source("scripts/00_check_setup.R", encoding = "UTF-8")
for (file in sort(list.files("R", pattern = "[.]R$", full.names = TRUE))) {
  source(file, encoding = "UTF-8")
}
# TP05 — Calcul distribué local : mapper des sommes/effectifs, puis réduire.
d <- clean_noria(read_noria())$data
# TODO 1 : répartir les TICKETS en lots de tailles7,53,176 ; vérifier chaque ID une fois.
# TODO 2 : dans chaque lot, mapper PAR CLE workflow vers somme et effectif observé.
# TODO 3 : shuffle : regrouper les seuls résumés par workflow, puis réduire sum/count.
# TODO 4 : comparer sommes, effectifs et moyennes par groupe au calcul central.
# TODO 5 : repartitionner les mêmes tickets en17lots ; la réponse doit être conservée.
# TODO 6 : contre-exemple list(rep(10,2),rep(20,8)) : moyenne globale18, moyenne des moyennes15.
# Défi : lot vide, workflow absent localement, lot tout-NA ; ne pas moyenner un NaN.
# Défi : identifier les lots et rejeter un identifiant de partition traité deux fois.
# Fonctions de référence disponibles si besoin : map_by_workflow(), reduce_by_workflow(),
# mapreduce_by_workflow(d) ; inspecter le code seulement après un premier essai.
# Livrable : tailles des lots, tableau central/distribué/écart et schéma map-shuffle-reduce.
