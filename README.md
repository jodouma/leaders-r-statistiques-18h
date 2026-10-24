# Noria Gestion — Data Science et ingénierie financière avec R

Un même cas pour apprendre à **contrôler des données, comparer des résultats et expliquer leurs limites**. Les 13 scripts complets et commentés analysent quatre indices historiques, composent un panier CAC–DAX et produisent un rapport local. Le code est fourni : vous observez, testez une variante et vérifiez son effet.

## Commencer en quatre étapes

1. **[Télécharger le cours en ZIP](https://github.com/jodouma/leaders-r-statistiques-18h/archive/refs/heads/main.zip)**, ou **Code → Download ZIP**. Aucun compte GitHub ni Git nécessaire.
2. Dans l’Explorateur Windows : clic droit sur le ZIP → **Extraire tout…**, dans **un nouveau dossier**. Garder vos anciens essais séparément.
3. Ouvrir **[pdf/01_aventure_noria.pdf](pdf/01_aventure_noria.pdf)** : suivre ce guide dans l’ordre. Il explique aussi l’installation de R et RStudio si nécessaire. **[Télécharger directement le guide](https://github.com/jodouma/leaders-r-statistiques-18h/raw/refs/heads/main/pdf/01_aventure_noria.pdf)** si l’aperçu GitHub gêne la lecture.
4. Double-cliquer **`course.Rproj`**. Dans **Files**, cliquer **l’icône R du projet → scripts → `00_premiers_pas.R`**. Dans **Source**, choisir **B01** avec le sélecteur de sections en bas, puis **Code → Run Region → Run Code Section** ; sous Windows, **Ctrl+Alt+T** exécute cette section entière. Continuer avec les Bxx indiqués dans le guide.

## Une seule route : 00 → 12, puis synthèse

**4 h 30 planifiées**, hors installation, téléchargement et pauses : ce budget comprend lecture, manipulation, comparaison et explication. Ce n’est pas un temps mesuré auprès d’étudiants ; vous pouvez prendre davantage de temps.

| Séquence | Ce que vous faites et pourquoi |
|---|---|
| **Départ · 15 min** | Ouvrir le projet et repérer les zones de travail |
| **00–03 · 60 min** | Nommer, calculer, importer et contrôler : savoir ce que contient l’entrée |
| **04–06 · 55 min** | Calculer des rendements, décrire et comparer : rendre les séries interprétables |
| **07–09 · 60 min** | Composer un panier, lire VaR et drawdown, tester un choc : relier hypothèses et effets |
| **10–12 · 65 min** | Explorer une simulation et un modèle avec le code fourni, puis automatiser le rapport |
| **Synthèse · 15 min** | Montrer une preuve Data Science et une lecture financière dans le rapport |

À chaque étape : **cas de référence → prédiction → variante → restauration → explication → fichier suivant**. Commencer chaque nouveau script par **B01** ; il reconstruit ses propres entrées. Aucun paquet supplémentaire ni code à écrire de zéro ; les dérivations mathématiques avancées restent facultatives.

Le dernier bloc ouvre automatiquement **le CSV réellement exporté**, pour comparer le tableau aux résultats annoncés. Après cette lecture, **recliquer l’onglet nommé `.R` dans Source avant de modifier un paramètre**. Pour retrouver le script suivant : **Files → icône R du projet → scripts → nom exact indiqué**. Au script 12, le CSV de comparaison s’ouvre, puis le HTML dans votre **navigateur par défaut** ; après une nouvelle exécution, actualiser le navigateur avec **Ctrl+R**, puis revenir à RStudio.

| Guide | Utilisation |
|---|---|
| [01_aventure_noria.pdf](pdf/01_aventure_noria.pdf) | Le parcours guidé complet : commencer ici |
| [02_reperes_R.pdf](pdf/02_reperes_R.pdf) | Gestes, vocabulaire français/anglais, unités et dépannage |
| [03_sources.pdf](pdf/03_sources.pdf) | Références, provenance des données et conventions |

**R de base ≥ 4.1 suffit ; aucun paquet additionnel.** Après téléchargement des logiciels et du cours, les analyses fonctionnent localement. Les résultats vont dans **`outputs/00/` à `outputs/12/`**. Le livrable final est **`outputs/12/rapport_noria.html`** ; garder **`comparaison_paniers.png`** à côté du HTML.

## Les données et les résultats

**EuStockMarkets** : **1 860 observations de 1991–1998**, sur DAX, SMI, CAC et FTSE. Le fichier d’entraînement ajoute un doublon exact et une ligne incomplète : **1 862 brutes → 1 861 distinctes → 1 860 complètes + 1 isolée**. Les **1 860 niveaux donnent 1 859 rendements**.

`observation` conserve l’ordre ; ce n’est pas une date reconstituée. Le panier utilise les rendements locaux et se rééquilibre à chaque observation ; son capital est en **UM pédagogiques**. Les séries d’indices sont utilisées telles quelles, sans traitement supplémentaire du change, des frais ou des dividendes ; leurs conventions peuvent différer. La VaR est un seuil historique par observation, le stress un scénario choisi, le bootstrap une simulation sous hypothèses et la régression une association contemporaine. Ces données anciennes et ces méthodes ne garantissent aucun résultat futur.

Pour reprendre : **Ctrl+S → Session → Restart R → onglet du fichier `.R` → B01**, puis les sections dans l’ordre. Garder `data/` intact et noter **avant → prédiction → après → explication**.

Les sources éditables sont dans `authoring/`. Pour reconstruire : installer les dépendances de `authoring/requirements.txt`, puis lancer **`python authoring/rebuild.py`**. Les captures réelles de RStudio gardent leur provenance. **`Rscript --vanilla tests/run_tests.R`** vérifie les scripts, expériences et calculs ; GitHub Actions exécute les contrôles sur Windows, macOS et Ubuntu.

Youssef Douma · Leaders University · octobre 2026
