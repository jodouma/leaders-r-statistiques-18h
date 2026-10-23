# TP01 — Corrigé commenté : démarrer · durée indicative : 90 min · R de base, depuis la racine du projet.
# 1. Ouvrez course.Rproj ; ouvrez ce fichier dans l'éditeur.
# 2. Exécutez une ligne à la fois pour relier le calcul à sa justification.
# 3. Relancez ensuite le corrigé entier dans une session R neuve.
# 4. Lancez source("checks/TP01.R", encoding = "UTF-8").
# Résultat final attendu du contrôle : « TP01 : contrôles réussis. »
# Les contrôles en fin de script vérifient les objets et les fichiers produits.
# Voir le PDF 10_TP01_demarrer.pdf pour les calculs à la main et les critères de réussite.

# Papier : valeurs triées 20,35,42,55,60,80 ; somme 292 ; n = 6.
# Moyenne = 292/6 ; médiane = (42+55)/2 ; >=60 : 2/6 ; absentes : 2/8.
durees <- c(42, NA, 35, 80, 55, NA, 20, 60)
n_total <- length(durees)
n_valides <- sum(!is.na(durees))
durees_valides <- durees[!is.na(durees)]
moyenne <- mean(durees, na.rm = TRUE)
mediane <- median(durees, na.rm = TRUE)
proportion_60 <- mean(durees_valides >= 60)
proportion_manquantes <- mean(is.na(durees))
resume_tp01 <- data.frame(n_total, n_valides, moyenne, mediane, proportion_60, proportion_manquantes)
interpretation_tp01 <- c(
  "La moyenne des 6 durées observées est 48,67 minutes et la médiane 48,5 minutes.",
  "Deux durées sur 6 atteignent 60 minutes (33,3 %) ; 2 tickets sur 8 sont manquants (25 %).",
  "NA indique une valeur inconnue ; remplacer les 2 NA par zéro sous-estimerait la moyenne.")
dir.create("results", showWarnings = FALSE)
write.csv(resume_tp01, "results/TP01_resume.csv", row.names = FALSE)
erreur_tp01 <- try(mean(objet_qui_n_existe_pas), silent = TRUE)
source("checks/TP01.R", local = TRUE, encoding = "UTF-8")
