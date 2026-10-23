# Exécuter depuis la racine : source("labs/TP04_inference.R")
source("scripts/00_check_setup.R", encoding = "UTF-8")
for (file in sort(list.files("R", pattern = "[.]R$", full.names = TRUE))) {
  source(file, encoding = "UTF-8")
}
# TP04 — Une question, un contraste et un objet de résultat.
d <- clean_noria(read_noria())$data
# TODO 1 : écrire la question et le contraste B-A, en minutes, avant le test.
# TODO 2 : extraire a et b ; calculer mean(b)-mean(a).
# TODO 3 : Welch via t.test(x = b, y = a, var.equal = FALSE).
# TODO 4 : inspecter class(), names(), str() de l'objet ; extraire p.value et conf.int.
# TODO 5 : interpréter ensemble estimation, IC95 %, p-valeur et portée de la simulation.
# TODO 6 : inverser x/y et constater le changement de signe, pas de p-valeur.
# TODO 7 : fixer workflow A comme référence ; utiliser la formule annoncée avant analyse :
# modele <- lm(resolution_minutes ~ workflow + complexity + team, data = d)
# TODO 8 : class(), attributes(), methods(class = "lm"), coef(), confint(), summary().
# TODO 9 : interpréter seulement workflowB : écart B-A ajusté sur complexité et équipe.
# TODO 10 : tracer résidus contre valeurs ajustées et un QQ-plot ; commenter une fragilité.
# Le modèle ajusté complète Welch ; ne pas choisir entre les deux selon les p-valeurs.
# Extension facultative : bootstrap indépendant dans chaque groupe, graine fixée.
# Livrable : tableau Welch, coefficient workflowB/IC, graphe des résidus et conclusion prudente.
