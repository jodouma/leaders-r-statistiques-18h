# Exemple guidé sur SIX lignes, AVANT les 241 lignes du TP02.
# Exécuter depuis course.Rproj ; aucun autre script requis.
mini_brut <- data.frame(id=c(1L,2L,2L,3L,4L,5L),
  groupe=c(" A ","B","B","A","B","A"),
  minutes=c(10,20,20,NA,-5,30), stringsAsFactors=FALSE)
# Papier : 6 -> 6 après espaces -> 5 après doublon -> 4 après NA -> 3 après négatif.
mini_d <- mini_brut
mini_audit <- data.frame(etape="import",avant=6L,apres=6L,exclues=0L)
mini_espaces <- sum(mini_d$groupe != trimws(mini_d$groupe)) # 1 cellule, pas une exclusion.
mini_d$groupe <- trimws(mini_d$groupe)
mini_audit <- rbind(mini_audit,data.frame(etape="espaces",avant=6,apres=6,exclues=0))
mini_doublons <- duplicated(mini_d$id)
mini_avant <- nrow(mini_d)
mini_d <- mini_d[!mini_doublons, , drop=FALSE] # La virgule signifie toutes les colonnes.
mini_audit <- rbind(mini_audit,data.frame(etape="doublons",avant=mini_avant,apres=nrow(mini_d),exclues=sum(mini_doublons)))
mini_absentes <- is.na(mini_d$minutes)
mini_avant <- nrow(mini_d)
mini_d <- mini_d[!mini_absentes, , drop=FALSE]
mini_audit <- rbind(mini_audit,data.frame(etape="absentes",avant=mini_avant,apres=nrow(mini_d),exclues=sum(mini_absentes)))
mini_invalides <- mini_d$minutes <= 0
mini_avant <- nrow(mini_d)
mini_d <- mini_d[!mini_invalides, , drop=FALSE]
mini_audit <- rbind(mini_audit,data.frame(etape="invalides",avant=mini_avant,apres=nrow(mini_d),exclues=sum(mini_invalides)))
stopifnot(all(mini_d$groupe %in% c("A","B")))
mini_d$groupe <- factor(mini_d$groupe,levels=c("A","B"))
mini_a <- mini_d$minutes[mini_d$groupe=="A"] # 10 et 30 : moyenne 20, sd 14,14.
mini_b <- mini_d$minutes[mini_d$groupe=="B"] # 20 : moyenne 20, sd NA (un seul ticket).
mini_stats <- data.frame(groupe=c("A","B"),n=c(length(mini_a),length(mini_b)),
  moyenne=c(mean(mini_a),mean(mini_b)),ecart_type=c(sd(mini_a),sd(mini_b)))
# Créer le dossier AVANT d'ouvrir un fichier, puis fermer le PDF avant lecture.
dir.create("results",showWarnings=FALSE)
write.csv(mini_d,"results/mini_nettoyage_clean.csv",row.names=FALSE)
write.csv(mini_audit,"results/mini_nettoyage_audit.csv",row.names=FALSE)
write.csv(mini_stats,"results/mini_nettoyage_stats.csv",row.names=FALSE)
pdf("results/mini_nettoyage.pdf",width=7,height=5)
plot(mini_d$id,mini_d$minutes,xlab="Identifiant",ylab="Durée (minutes)",main="Trois durées conservées")
dev.off()
stopifnot(nrow(mini_d)==3,mini_espaces==1,identical(mini_audit$apres,c(6L,6L,5L,4L,3L)) || all(mini_audit$apres==c(6,6,5,4,3)))
print(mini_audit)
print(mini_stats)
