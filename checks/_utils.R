# Utilitaires explicites des contrôles étudiants ; aucune réponse de TP n'est chargée.
verifier <- function(ok, message) {
  if (!isTRUE(ok)) stop(paste("À corriger :", message), call. = FALSE)
}
besoin <- function(nom) {
  e <- parent.frame()
  verifier(exists(nom, envir = e, inherits = FALSE), paste("créer l'objet", nom, "dans votre script."))
  get(nom, envir = e, inherits = FALSE)
}
proche <- function(x, attendu, tolerance = 1e-6) {
  is.numeric(x) && length(x) == length(attendu) && !anyNA(x) &&
    all(is.finite(x)) && all(abs(as.numeric(x) - as.numeric(attendu)) <= tolerance)
}
texte_personnel <- function(x, minimum = 3L) {
  is.character(x) && length(x) >= minimum && !anyNA(x) &&
    all(nchar(x) >= 20) && !any(grepl("TODO|à compléter|a completer", x, ignore.case = TRUE))
}
verifier_csv <- function(chemin, attendu) {
  verifier(file.exists(chemin), paste("exporter", chemin, "avec row.names = FALSE."))
  lu <- read.csv(chemin, na.strings = c("", "NA"), stringsAsFactors = FALSE)
  verifier(identical(names(lu), names(attendu)), paste("colonnes de", chemin, ": conserver les noms demandés."))
  attendu[] <- lapply(attendu, function(x) if (is.factor(x)) as.character(x) else x)
  verifier(isTRUE(all.equal(lu, attendu, check.attributes = FALSE, tolerance = 1e-7)),
           paste("le contenu de", chemin, "doit correspondre à votre objet en mémoire."))
}
verifier_pdf <- function(chemin) {
  verifier(file.exists(chemin), paste("produire", chemin, "puis fermer le périphérique avec dev.off()."))
  verifier(file.info(chemin)$size > 1000, paste(chemin, ": PDF vide ou non fermé."))
  entete <- readBin(chemin, what = "raw", n = 5)
  verifier(identical(rawToChar(entete), "%PDF-"), paste(chemin, "doit être un vrai fichier PDF."))
}
verifier_audit <- function(audit) {
  verifier(is.data.frame(audit) && identical(names(audit),
    c("etape", "n_avant", "n_apres", "n_exclues", "n_cellules_modifiees")),
    "audit : cinq colonnes nommées etape/n_avant/n_apres/n_exclues/n_cellules_modifiees.")
  verifier(identical(as.character(audit$etape),
    c("import", "espaces", "doublons", "durees_absentes", "durees_invalides", "facteurs")),
    "audit : conserver une ligne par règle et l'ordre demandé.")
  verifier(proche(audit$n_avant, c(241,241,241,240,237,236)) &&
    proche(audit$n_apres, c(241,241,240,237,236,236)) &&
    proche(audit$n_exclues, c(0,0,1,3,1,0)) &&
    proche(audit$n_cellules_modifiees, c(0,7,0,0,0,0)),
    "audit : contrôler les comptes après chaque règle, sans fusionner les exclusions.")
}
verifier_clean <- function(d, exclusions) {
  verifier(is.data.frame(d) && identical(names(d),
    c("ticket_id", "workflow", "resolution_minutes", "complexity", "satisfaction", "team")),
    "tableau nettoyé : conserver les six colonnes initiales dans leur ordre.")
  verifier(nrow(d) == 236 && !anyDuplicated(d$ticket_id), "tableau nettoyé : vérifier effectif et unicité.")
  verifier(!anyNA(d$resolution_minutes) && all(is.finite(d$resolution_minutes)) &&
    all(d$resolution_minutes > 0), "durées : exclure valeurs absentes ou non positives.")
  verifier(identical(sort(d$ticket_id), setdiff(1:240, c(21L,87L,154L,203L))),
    "tableau nettoyé : vérifier quels identifiants ont été exclus.")
  verifier(is.factor(d$workflow) && identical(levels(d$workflow), c("A","B")) &&
    is.factor(d$team) && identical(levels(d$team), c("Atlas","Boreal","Cedre")),
    "créer les facteurs avec niveaux explicites, après contrôle des libellés.")
  verifier(!anyNA(d$workflow) && !anyNA(d$team) &&
    identical(as.integer(table(d$workflow)), c(117L,119L)), "facteurs : revoir les modalités et effectifs A/B.")
  verifier(sum(is.na(d$satisfaction)) == 12, "satisfaction : conserver les durées valides malgré une note absente.")
  verifier(is.data.frame(exclusions) && identical(names(exclusions), c("ticket_id","motif")),
    "exclusions : colonnes ticket_id et motif.")
  verifier(identical(sort(exclusions$ticket_id), c(21L,87L,154L,203L)) &&
    all(exclusions$motif[match(c(21L,87L,154L,203L),exclusions$ticket_id)] ==
      c("duree_absente","duree_absente","duree_absente","duree_invalide")),
    "exclusions : une ligne par durée exclue et un motif fidèle à la règle.")
}
verifier_descriptifs <- function(tab, d) {
  verifier(is.data.frame(tab) && identical(names(tab),
    c("workflow","n","moyenne","ecart_type","q1","mediane","q3")) && nrow(tab)==2,
    "descriptifs : deux lignes A/B et les sept colonnes demandées.")
  verifier(identical(as.character(tab$workflow),c("A","B")), "descriptifs : ordonner les lignes A puis B.")
  for (i in 1:2) {
    x <- d$resolution_minutes[d$workflow == c("A","B")[i]]
    cible <- c(length(x), mean(x), sd(x), unname(quantile(x,.25,type=7)), median(x), unname(quantile(x,.75,type=7)))
    verifier(proche(unlist(tab[i,-1],use.names=FALSE), cible),
      paste("descriptifs du groupe", c("A","B")[i], ": revoir n, moyenne, sd et quantile(type=7)."))
  }
}
verifier_comparaison <- function(tab, test, d) {
  verifier(inherits(test,"htest") && grepl("Welch", test$method), "utiliser un test t de Welch indépendant.")
  a <- d$resolution_minutes[d$workflow=="A"]
  b <- d$resolution_minutes[d$workflow=="B"]
  verifier(proche(unname(test$estimate), c(mean(b),mean(a))), "t.test : passer x=B et y=A pour le contraste B-A.")
  verifier(proche(unname(attr(test$conf.int,"conf.level")),.95), "demander un intervalle à 95 %.")
  verifier(is.data.frame(tab) && identical(names(tab),
    c("contraste","delta_minutes","ic_bas","ic_haut","p_valeur")) && nrow(tab)==1,
    "comparaison : une ligne, cinq colonnes nommées comme demandé.")
  verifier(identical(as.character(tab$contraste),"B - A"), "étiqueter explicitement B - A.")
  verifier(proche(unlist(tab[1,-1],use.names=FALSE),
    c(-4.56478488831429,-9.14764830676072,.0180785301321356,.0509031648494577), tolerance=1e-6),
    "contraste : revoir les groupes, le signe B-A, l'IC et l'accès nommé à p.value.")
  verifier(proche(c(tab$ic_bas,tab$ic_haut), unname(test$conf.int)) &&
    proche(tab$p_valeur,test$p.value), "extraire IC et p du même objet htest.")
}
