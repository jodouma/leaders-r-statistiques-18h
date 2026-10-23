# Statistiques avec R — Leaders University

**18 heures · 2 jours · 6 TP · un projet complet à défendre.**

Du premier vecteur à une recommandation reproductible : vous analysez un pilote fictif de Noria Services, puis transférez la démarche à de vraies mesures historiques. Le cours est en français, avec les noms et termes usuels de R en anglais.

## Commencer

1. Télécharger le dépôt : **Code → Download ZIP**, puis extraire le dossier.
2. Suivre le [guide Windows / macOS / Ubuntu](pdf/00_demarrer.pdf).
3. Ouvrir `course.Rproj` dans RStudio, ou choisir le dossier dans R GUI.
4. Dans la console R, lancer le contrôle :

```r
source("scripts/00_check_setup.R", encoding = "UTF-8")
```

**Aucun compte GitHub, Git, Hadoop ni paquet R externe requis.** RStudio est facultatif. Le travail principal fonctionne hors ligne après installation de R et téléchargement du dossier. Les scripts visent R ≥ 4.1 ; les environnements réellement vérifiés sont indiqués ci-dessous.

## Les PDF à lire

| Objectif | Support |
|---|---|
| Se préparer | [Installation et dépannage](pdf/00_demarrer.pdf) |
| Comprendre le week-end | [Parcours, compétences et barème](pdf/01_parcours_18h.pdf) |
| Apprendre les concepts | [Cours visuel — 24 pages](pdf/02_cours_visuel.pdf) |
| Comprendre les données | [Dictionnaire, audit et références](pdf/03_donnees_et_sources.pdf) |
| Suivre la projection | [Diapositives — 32 vues](pdf/04_projection.pdf) |
| S’autoévaluer | [Diagnostic d’entrée](pdf/diagnostic_entree.pdf) · [Mémo R](pdf/memo_R.pdf) |
| Vérifier après tentative | [Corrigés et preuves](pdf/80_corriges_et_preuves.pdf) |
| Aller plus loin | [Extension solo](pdf/extension_solo.pdf) · [Transfert sur données réelles](pdf/05_transfert_donnees_reelles.pdf) |

## Six travaux pratiques

| TP | Mission | Durée | Fichier de départ |
|---|---|---:|---|
| [01](pdf/TP01_vectors.pdf) | Vecteurs, NA, indexation | 70 min | [TP01_vectors.R](labs/TP01_vectors.R) |
| [02](pdf/TP02_cleaning.pdf) | Import, audit, nettoyage, exploration | 90 min | [TP02_cleaning.R](labs/TP02_cleaning.R) |
| [03](pdf/TP03_matrices.pdf) | Matrices, `apply()`, fonctions | 75 min | [TP03_matrices.R](labs/TP03_matrices.R) |
| [04](pdf/TP04_inference.pdf) | Welch, objets statistiques, modèle ajusté | 100 min | [TP04_inference.R](labs/TP04_inference.R) |
| [05](pdf/TP05_mapreduce.pdf) | Map, shuffle, reduce et moyenne pondérée | 80 min | [TP05_mapreduce.R](labs/TP05_mapreduce.R) |
| [06](pdf/TP06_capstone.pdf) | Analyse individuelle et recommandation | 120 min | [TP06_capstone.R](labs/TP06_capstone.R) |

Les quatre séances durent **4 h 30 chacune, hors pauses**. Les TP représentent **8 h 55** ; les autres activités comprennent apports courts, diagnostic, prédictions, vérifications et défenses. Chaque TP contient un noyau individuel, des indices gradués et un défi. Les extensions sont facultatives, hors des 18 h.

```mermaid
flowchart LR
  A[Question] --> B[CSV brut]
  B --> C[Audit et règles]
  C --> D[Exploration]
  D --> E[Estimation et incertitude]
  E --> F[Modèle et critique]
  F --> G[Décision défendue]
```

## Reproduire la référence

Depuis la racine du projet, dans R :

```r
source("scripts/01_run_all.R", encoding = "UTF-8")
source("tests/run_tests.R", encoding = "UTF-8")
```

Les CSV, figures PDF, audit et versions sont écrits dans `results/`. Les données brutes sont conservées. Les [solutions commentées](solutions/) servent après une tentative. Un [exemple réel](examples/airquality_transfer.R) et une [figure des intervalles](examples/noria_visual_summary.R) sont aussi exécutables.

Le scénario est **synthétique** : 241 lignes reçues, 240 tickets uniques, 236 délais valides. Welch estime **B − A**. Le modèle secondaire `workflow + complexity + team` est fixé par le protocole pédagogique ; les deux analyses sont rapportées sans choisir selon leur p-valeur. La note finale récompense les preuves, la compréhension et les limites, pas la découverte d’un résultat secret.

## Périmètre et validation

- Le noyau couvre langage R, vecteurs, matrices, `apply()`, fonctions, objets statistiques et `attributes()`, analyse et restitution.
- Hadoop, HDFS et RHadoop sont expliqués. **Le TP MapReduce est une simulation locale séquentielle, sans exécution RHadoop.** Cette adaptation de la partie pratique du plan officiel doit être validée par le coordinateur.
- Tests, pipeline, six corrigés et exemples exécutés localement sous **R 4.6.1 / macOS ARM64**. Le [workflow de CI](.github/workflows/r-check.yml) vérifie R sur Ubuntu, Windows et macOS ; son état courant est visible dans [Actions](https://github.com/jodouma/leaders-r-statistiques-18h/actions).
- Aucune donnée d’étudiant, d’entreprise ou du document administratif source n’est publiée. Les mesures réelles du bonus sont le jeu `datasets::airquality` distribué avec R ; leur provenance est détaillée dans le PDF.
- Le guide formateur et les documents administratifs restent dans le dossier local du formateur.

Les supports de lecture sont en PDF. Les fichiers JSON de `authoring/` sont les sources de construction. Pour les mainteneurs : `python -m pip install -r authoring/requirements.txt`, puis `python authoring/build_pdfs.py authoring/content.json --out pdf`. Les étudiants n’ont pas besoin de Python.

Préparation : **Youssef Douma** · Leaders University · octobre 2026.
