# TP01 — Démarrer et décrire · durée indicative : 90 min · R de base, depuis la racine du projet.
# 1. Ouvrez course.Rproj ; ouvrez ce fichier dans l'éditeur.
# 2. Lisez la première consigne puis exécutez une ligne avec Ctrl/Cmd + Entrée.
# 3. Remplacez les TODO ; exécutez ensuite tout le fichier de haut en bas.
# 4. Lancez source("checks/TP01.R", encoding = "UTF-8").
# Résultat final attendu du contrôle : « TP01 : contrôles réussis. »
# Un contrôle rouge nomme l'objet à corriger ; ne copiez pas le corrigé.
# Voir le PDF 10_TP01_demarrer.pdf pour les calculs à la main et les critères de réussite.

# AVANT R : triez les 6 durées présentes, calculez somme/6, médiane et 2 proportions.
# « >= 60 parmi les durées observées » et « manquantes parmi tous les tickets »
# n'ont pas le même dénominateur. Inscrivez le calcul dans vos commentaires.
durees <- c(42, NA, 35, 80, 55, NA, 20, 60)
# Exemple entièrement résolu, distinct des données de l'exercice :
mini <- c(10, NA, 30)
mean(mini)                    # NA : R ne choisit pas une règle à votre place.
mean(mini, na.rm = TRUE)      # (10 + 30) / 2 = 20.
mini[!is.na(mini)]            # Conserver les valeurs présentes.
# TODO : remplacez les NA par des calculs utilisant durees, pas par les réponses.
n_total <- NA_integer_
n_valides <- NA_integer_
moyenne <- NA_real_
mediane <- NA_real_
proportion_60 <- NA_real_     # >= 60 parmi les durées observées.
proportion_manquantes <- NA_real_ # NA parmi tous les tickets.
durees_valides <- numeric(0) # TODO : indexation logique.
# TODO : produire un tableau d'une ligne avec ces six indicateurs.
resume_tp01 <- data.frame()
# TODO : remplacer chaque chaîne par une phrase personnelle, précise et chiffrée.
interpretation_tp01 <- c("TODO moyenne et médiane", "TODO les deux dénominateurs", "TODO NA et zéro")
# TODO : dir.create("results", showWarnings = FALSE) ; exporter resume_tp01
# dans results/TP01_resume.csv avec row.names = FALSE.
# Exemple d'erreur attendu : objet inexistant, sans interrompre la suite.
erreur_tp01 <- try(mean(objet_qui_n_existe_pas), silent = TRUE)
# Lancez maintenant checks/TP01.R ; il doit refuser un fichier encore incomplet.
