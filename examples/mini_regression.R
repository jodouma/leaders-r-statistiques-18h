# EXTENSION FACULTATIVE — hors tronc commun de 18 h. R de base uniquement.
# Depuis la racine : source("examples/mini_regression.R", encoding = "UTF-8")
# Question : quelle différence B-A à complexité et équipe comparables ?
# Modèle additif : E(Y | W,C,T) = beta0 + betaW*W + betaC*C
#                              + betaB*I_Boreal + betaD*I_Cedre.
# Y : minutes ; W=1 si workflow B (0 si A) ; C : complexité, de 1 à 5.
# betaW : minutes pour B-A ; betaC : minutes par point de complexité.
# Atlas est la référence équipe. Complexity/team précèdent le workflow.
# Exemple manuel de coefficients INVENTÉS : 20 - 3*W + 4*C.
# Pour C=2 et Atlas : A=28 min, B=25 min, différence ajustée=-3 min.
predire_jouet <- function(W, C) 20 - 3 * W + 4 * C
stopifnot(predire_jouet(0, 2) == 28, predire_jouet(1, 2) == 25)
print(predire_jouet(1, 2) - predire_jouet(0, 2))

# Priorité au CSV produit par votre TP02 ; la reprise permet de découvrir l'option.
# Aucun source() des modules de référence n'est nécessaire.
chemin_option <- "results/TP02_clean.csv"
if (!file.exists(chemin_option)) {
  chemin_option <- "data/noria_clean_reprise.csv"
  message("CSV de reprise fourni : ceci ne valide pas votre nettoyage du TP02.")
}
if (!file.exists(chemin_option)) stop("Ouvrir course.Rproj, puis lancer depuis sa racine.")
option_d <- read.csv(chemin_option, na.strings = c("", "NA"),
  stringsAsFactors = FALSE, fileEncoding = "UTF-8",
  colClasses = c("integer", "character", "numeric", "numeric", "numeric", "character"))
stopifnot(nrow(option_d) > 1L, !anyNA(option_d$ticket_id),
  !anyDuplicated(option_d$ticket_id), all(is.finite(option_d$resolution_minutes)),
  all(option_d$resolution_minutes > 0), !anyNA(option_d$workflow),
  all(option_d$workflow %in% c("A", "B")),
  all(c("A", "B") %in% option_d$workflow))

stopifnot(!anyNA(option_d$complexity), all(option_d$complexity %in% 1:5),
  !anyNA(option_d$team), all(option_d$team %in% c("Atlas", "Boreal", "Cedre")))
option_d$workflow <- factor(option_d$workflow, levels = c("A", "B"))
option_d$team <- factor(option_d$team, levels = c("Atlas", "Boreal", "Cedre"))
modele_option <- lm(resolution_minutes ~ workflow + complexity + team, data = option_d)
# Le niveau A explicite garantit le coefficient workflowB = B-A.
ic_modele <- confint(modele_option)["workflowB", ]
resultat_regression <- data.frame(contraste = "B - A ajuste", unite = "minutes",
  estimation = unname(coef(modele_option)["workflowB"]),
  ic_bas = unname(ic_modele[1]), ic_haut = unname(ic_modele[2]))
print(resultat_regression)
print(summary(residuals(modele_option)))
# Pour explorer manuellement : plot(modele_option, which = c(1, 2, 3, 5)).
# Hypothèses : effet additif, lien linéaire avec complexity, erreurs indépendantes ;
# IC usuels : variance constante et référence d'erreurs adaptée. Inspecter résidus,
# forme du lien et points influents. Les graphiques ne prouvent pas l'indépendance.
# Ajuster change la question : ce coefficient n'est pas le contraste brut de Welch.
# Ne pas choisir l'analyse après comparaison des p-valeurs ; pas de preuve causale
# créée par lm(). Noria est synthétique : aucune conclusion commerciale réelle.
