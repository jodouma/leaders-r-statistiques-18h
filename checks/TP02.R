# Contrôle des objets ET des fichiers : les réponses ne sont pas préchargées.
source("checks/_utils.R", local = TRUE, encoding = "UTF-8")
r <- besoin("raw")
verifier(is.data.frame(r) && nrow(r)==241 && sum(duplicated(r$ticket_id))==1 &&
  sum(r$workflow != trimws(r$workflow))==3 && sum(r$team != trimws(r$team))==4,
  "raw doit rester le fichier brut, avant nettoyage.")
verifier(proche(besoin("n_espaces_workflow"),3) && proche(besoin("n_espaces_team"),4),
  "compter séparément les cellules modifiées de workflow et team.")
verifier(identical(as.integer(besoin("ids_doublons")),17L), "repérer le ticket répété, pas son numéro de ligne.")
verifier(identical(sort(as.integer(besoin("ids_absents"))),c(21L,87L,154L)), "enregistrer les identifiants des durées absentes.")
verifier(identical(as.integer(besoin("ids_invalides")),203L), "enregistrer l'identifiant de durée invalide.")
verifier_audit(besoin("audit"))
verifier_clean(besoin("clean"),besoin("exclusions"))
verifier(proche(besoin("n_satisfaction_absente"),12), "compter la satisfaction manquante conservée.")
verifier(is.function(besoin("resumer_durees")), "définir resumer_durees(x).")
autre_resume <- resumer_durees(c(10,20,30,40))
# Deux présentations valides : vecteur numérique, ou tableau d'une ligne.
if (is.data.frame(autre_resume) && nrow(autre_resume) == 1L) {
  autre_resume <- unlist(autre_resume, use.names = FALSE)
}
verifier(proche(unname(autre_resume), c(4,25,sd(c(10,20,30,40)),17.5,25,32.5)),
  "resumer_durees doit fonctionner sur un autre vecteur, avec quantiles de type 7.")
verifier_descriptifs(besoin("descriptifs"),clean)
verifier_csv("results/TP02_clean.csv",clean)
verifier_csv("results/TP02_audit.csv",audit)
verifier_csv("results/TP02_exclusions.csv",exclusions)
verifier_csv("results/TP02_descriptifs.csv",descriptifs)
verifier_pdf("results/TP02_graphiques.pdf")
message("TP02 : contrôles réussis.")
