# Exemple guidé AVANT TP01 ; exécuter chaque ligne, puis expliquer le résultat.
# Aucun paquet et aucun fichier R/ chargé ; ces données diffèrent du TP.
x <- c(10, NA, 20, 30)
# Papier : 4 positions, 3 valeurs présentes, somme 60, moyenne 20, médiane 20.
length(x)                  # 4 positions, NA compris.
sum(!is.na(x))             # 3 valeurs présentes.
mean(x)                    # NA : une règle manque pour les valeurs inconnues.
mean(x, na.rm = TRUE)      # 60 / 3 = 20.
y <- x[!is.na(x)]          # Le masque logique choisit les éléments TRUE.
sort(y)                   # 10, 20, 30.
median(y)                 # La valeur centrale vaut 20.
mean(y >= 20)             # 2/3 parmi les durées connues.
mean(is.na(x))            # 1/4 parmi toutes les positions.
# Une fonction peut recevoir un argument positionnel ou nommé.
identical(mean(x, na.rm=TRUE), mean(x=x, na.rm=TRUE)) # TRUE.
# Une faute volontaire capturée : le script peut poursuivre.
erreur_mini_vecteur <- try(mean(x, na.rm=VRAI), silent=TRUE)
inherits(erreur_mini_vecteur,"try-error") # TRUE ; en R, écrire TRUE, pas VRAI.
stopifnot(length(y)==3, mean(y)==20, median(y)==20)
