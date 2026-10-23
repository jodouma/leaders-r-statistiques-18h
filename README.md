# Statistiques avec R — Leaders University

**18 heures · 2 jours · 4 TP · des équations au projet individuel.**

Une question, une équation, un petit calcul à la main, sa traduction en R, puis une interprétation. Le cours accueille des profils IT et non IT : vocabulaire des données, objets R, exemples résolus et consignes pour écrire, enregistrer et relancer son travail.

## Commencer

1. **Code → Download ZIP**, puis extraire le dossier ; Git et un compte GitHub sont facultatifs.
2. Suivre le [guide Windows / macOS / Ubuntu](pdf/00_demarrer.pdf).
3. Ouvrir `course.Rproj` dans RStudio, puis le [premier essai guidé](pdf/00_premiers_pas.pdf).
4. Garder le [sommaire PDF cliquable](COMMENCER_ICI.pdf) comme point de départ.

```r
# Console R, depuis le dossier extrait : vérifier l'installation.
source("scripts/00_check_setup.R", encoding = "UTF-8")
```

**R de base suffit.** Aucun paquet externe requis ; RStudio est facultatif. Les fichiers et données fonctionnent hors ligne après installation et téléchargement. Le contrôle d’installation ne valide aucune réponse de TP.

## Lire, comprendre, pratiquer

| Besoin | PDF |
|---|---|
| Tout garder dans un seul fichier | [Dossier étudiant avec sommaire et liens internes](Dossier_etudiant_R_18h.pdf) |
| Choisir son système | [Installation et dépannage](pdf/00_demarrer.pdf) |
| Faire son premier fichier | [Écrire → enregistrer → exécuter → redémarrer](pdf/00_premiers_pas.pdf) |
| Suivre les quatre séances | [Parcours et lectures](pdf/01_parcours_18h.pdf) |
| Comprendre avant de coder | [Cours visuel : maths, statistiques et R](pdf/02_cours_visuel.pdf) |
| Connaître chaque variable | [Données, règles et sources](pdf/03_donnees_et_sources.pdf) |
| Observer un exemple complet | [Mini-exemples guidés](pdf/06_exemples_guides.pdf) |
| Retrouver une commande | [Mémo R et notations](pdf/14_memo_R.pdf) |
| Se situer | [Diagnostic sans note](pdf/diagnostic_entree.pdf) |
| Suivre en classe | [Projection visuelle](pdf/04_projection.pdf) |
| Vérifier après une tentative | [Corrigés et preuves](pdf/80_corriges_et_preuves.pdf) |

Le cours commence par R, ses origines, son objectif statistique et un exemple actuel d’usage professionnel. Il distingue observation, variable, population et échantillon, puis montre vecteur, matrice, array, liste et data frame. Les calculs incluent proportions, moyenne, médiane, variance, écart-type, quartiles, différence de moyennes, erreur standard, test de Welch et intervalle de confiance.

## Quatre TP obligatoires

| TP | Mission | Durée | Fichier à compléter |
|---|---|---:|---|
| [01](pdf/10_TP01_demarrer.pdf) | Vecteurs, valeurs manquantes et dénominateurs | 90 min | [TP01_demarrer.R](labs/TP01_demarrer.R) |
| [02](pdf/11_TP02_preparer.pdf) | Importer, auditer, nettoyer, décrire | 120 min | [TP02_preparer.R](labs/TP02_preparer.R) |
| [03](pdf/12_TP03_comparer.pdf) | Comparer B − A avec l’incertitude | 120 min | [TP03_comparer.R](labs/TP03_comparer.R) |
| [04](pdf/13_TP04_projet.pdf) | Repartir du brut et défendre une décision | 150 min | [TP04_projet.R](labs/TP04_projet.R) |

Les quatre séances durent **4 h 30 chacune, hors pauses**. Les TP occupent **8 heures**, dont **6 h 05 de travail individuel prévu**. Les autres temps servent aux petits calculs, apports courts, prédictions, vérifications et défenses. Ce sont des durées pédagogiques à confirmer par un pilote en classe.

Après avoir complété et enregistré le TP01, dans une session R redémarrée :

```r
source("labs/TP01_demarrer.R", encoding = "UTF-8")
source("checks/TP01.R", encoding = "UTF-8")
```

Adapter le numéro pour les autres TP. Un fichier non complété doit échouer avec un message utile. Les contrôles examinent vos objets et exports ; l’enseignant évalue les justifications et l’oral. Les [solutions commentées](solutions/) viennent après une tentative. Le CSV de reprise du TP03 aide à continuer ; il ne valide pas le nettoyage du TP02.

```mermaid
flowchart LR
  Q[Question] --> E[Équation]
  E --> M[Petit calcul à la main]
  M --> R[Code R]
  R --> V[Résultat vérifié]
  V --> D[Décision et limites]
```

## Après le cœur

Les [extensions](pdf/20_extensions.pdf) introduisent régression, bootstrap, matrices approfondies et MapReduce par clé ; elles sont **facultatives, hors des 18 heures**, sans points indispensables au barème. Le [transfert sur airquality](pdf/05_transfert_donnees_reelles.pdf) utilise des données historiques livrées avec R.

Les fichiers de première édition sont conservés dans `legacy/`. Pour reproduire l’analyse complète de référence, y compris le modèle secondaire et l’agrégation locale :

```r
source("scripts/01_run_all.R", encoding = "UTF-8")
```

Cette démonstration charge les fonctions de référence et ne valide aucun TP étudiant. **Aucun déploiement RHadoop réel n’est implémenté.** Le report de cette partie du plan officiel doit être validé avec le coordinateur.

## Données et validation

Noria est un scénario **synthétique** : 241 lignes reçues, 240 tickets uniques et 236 délais valides. Le contraste principal est **B − A**. Le gain utile de 5 minutes est un critère fictif du protocole pédagogique. On ne choisit pas une analyse selon sa p-valeur. Le modèle ajusté reste une extension.

Les vérifications techniques sont exécutables depuis la racine :

```r
source("tests/run_tests.R", encoding = "UTF-8")
source("tests/learner_checks.R", encoding = "UTF-8")
```

Le second test utilise des dossiers et environnements séparés : les quatre solutions passent, les quatre starters non complétés échouent, les fichiers manquants et doublons contradictoires sont rejetés. Le [workflow](.github/workflows/r-check.yml) exécute R sur Ubuntu, Windows et macOS ; consulter son résultat dans [Actions](https://github.com/jodouma/leaders-r-statistiques-18h/actions). La validation automatisée ne remplace pas un essai avec de vrais débutants ni une installation interactive sur chaque OS.

Les sources primaires sur R et les conventions statistiques figurent dans les PDF. Aucune donnée d’étudiant, d’entreprise ou du document administratif source n’est publiée. Le guide formateur reste dans le dossier local du formateur.

Les supports de lecture sont en PDF. `authoring/content.json` contient les sources de construction. Pour les mainteneurs : installer `authoring/requirements.txt`, puis exécuter `python authoring/build_pdfs.py authoring/content.json --out pdf` depuis la racine. Les étudiants n’ont pas besoin de Python.

Préparation : **Youssef Douma** · Leaders University · octobre 2026.
