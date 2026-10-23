# Statistiques avec R — à votre rythme

**Leaders University · Master · 18 heures accompagnées · 4 TP individuels.**

Le cours est une **autoformation accompagnée** : vous progressez par preuves, le formateur vous aide au point de blocage. Les profils IT et non IT suivent le même cœur, avec des aides et approfondissements différents. Les temps sont des repères ; personne n’attend que toute la classe termine une étape.

## Ouvrir le bon PDF

**Commencez par [00_LIRE_MOI.pdf](00_LIRE_MOI.pdf)**, puis gardez [COMMENCER_ICI.pdf](COMMENCER_ICI.pdf) ouvert. Les supports à lire sont des PDF ; ce README est le point d’entrée de GitHub.

1. **Code → Download ZIP**, puis extraire réellement le dossier. Git et un compte GitHub sont facultatifs.
2. Suivre [00_demarrer.pdf — Windows / macOS / Ubuntu](pdf/00_demarrer.pdf).
3. Ouvrir `course.Rproj` dans RStudio, ou choisir le dossier extrait dans R.
4. Réussir le premier fichier de [00_premiers_pas.pdf](pdf/00_premiers_pas.pdf) : écrire, enregistrer, exécuter, redémarrer.
5. Suivre [01_parcours_18h.pdf](pdf/01_parcours_18h.pdf), un niveau après l’autre.

```r
# Console R, depuis le dossier extrait : préparation technique seulement.
source("scripts/00_check_setup.R", encoding = "UTF-8")
```

**R de base suffit.** Aucun paquet externe requis ; RStudio est facultatif. Après installation et téléchargement, le cœur fonctionne hors ligne. Le contrôle d’installation ne valide aucune réponse de TP.

## Votre boucle de travail

**Question → équation → petit calcul → exemple → votre code → vérification → explication.**

Consultez seulement les sections utiles au niveau courant dans [02_cours_visuel.pdf](pdf/02_cours_visuel.pdf), puis essayez un autre jeu de nombres dans [06_exemples_guides.pdf](pdf/06_exemples_guides.pdf). Complétez votre script, enregistrez-le et relancez-le dans une session R vide. Le message vert du contrôle accompagne votre raisonnement ; il ne note ni vos explications ni la lisibilité des graphiques.

| Niveau | Mission | Énoncé PDF | Votre fichier |
|---|---|---|---|
| 0 | Ouvrir, écrire et relancer | [00_premiers_pas.pdf](pdf/00_premiers_pas.pdf) | `premier_essai.R` à créer |
| 1 | Décrire un vecteur et ses absences | [10_TP01_demarrer.pdf](pdf/10_TP01_demarrer.pdf) | [TP01_demarrer.R](labs/TP01_demarrer.R) |
| 2 | Auditer, nettoyer et décrire | [11_TP02_preparer.pdf](pdf/11_TP02_preparer.pdf) | [TP02_preparer.R](labs/TP02_preparer.R) |
| 3 | Comparer B − A avec son incertitude | [12_TP03_comparer.pdf](pdf/12_TP03_comparer.pdf) | [TP03_comparer.R](labs/TP03_comparer.R) |
| 4 | Repartir du brut et justifier une décision | [13_TP04_projet.pdf](pdf/13_TP04_projet.pdf) | [TP04_projet.R](labs/TP04_projet.R) |

Après votre tentative enregistrée, exemple pour TP01 :

```r
source("labs/TP01_demarrer.R", encoding = "UTF-8")
source("checks/TP01.R", encoding = "UTF-8")
```

Les quatre contrôles sont `checks/TP01.R`, `TP02.R`, `TP03.R` et `TP04.R`. Un starter non complété doit échouer avec un message utile. Les chemins complets et les critères de passage sont dans chaque énoncé PDF.

## Si vous bloquez, si vous avancez vite

- Lire la **première erreur**, puis essayer un petit cas dans [14_memo_R.pdf](pdf/14_memo_R.pdf).
- Ouvrir [07_aides_progressives.pdf](pdf/07_aides_progressives.pdf) : prendre un indice, refaire, vérifier.
- Après environ cinq minutes sans progrès, montrer au coach le fichier, la ligne, le message et ce qui était attendu.
- Enregistrer son point d’arrêt et la prochaine action ; reprendre après une pause ou après le week-end.
- Si le cœur du niveau est acquis, choisir un défi facultatif. Les échanges entre pairs et partages de portfolio sont facultatifs.

Les [80_corriges_et_preuves.pdf](pdf/80_corriges_et_preuves.pdf) et [solutions commentées](solutions/) viennent après une tentative et une aide. Refermez-les puis refaites le passage sur votre propre fichier. Le CSV de reprise du TP03 permet de continuer ; il ne valide pas le nettoyage du TP02.

## Tous les supports PDF

| Besoin | Fichier |
|---|---|
| Lecture dans un seul fichier avec liens internes | [Dossier_etudiant_R_18h.pdf](Dossier_etudiant_R_18h.pdf) |
| R, statistiques, équations et structures de données | [02_cours_visuel.pdf](pdf/02_cours_visuel.pdf) |
| Variables, règles et sources du cas | [03_donnees_et_sources.pdf](pdf/03_donnees_et_sources.pdf) |
| Cartes de révision facultatives | [04_projection.pdf](pdf/04_projection.pdf) |
| Diagnostic sans note | [diagnostic_entree.pdf](pdf/diagnostic_entree.pdf) |
| Modèles, bootstrap, matrices et MapReduce facultatifs | [20_extensions.pdf](pdf/20_extensions.pdf) |
| Transfert sur des mesures historiques | [05_transfert_donnees_reelles.pdf](pdf/05_transfert_donnees_reelles.pdf) |

Les **18 heures** forment une fenêtre d’accompagnement sur deux jours, pauses supplémentaires. Le parcours autorise des rythmes différents et une reprise ultérieure du portfolio. Le barème du cœur reste **15 / 25 / 30 / 30** ; aucune extension ne rapporte de points indispensables. Le coach aide, questionne et relit les preuves, sans imposer une progression collective.

## Référence et validation technique

Noria est un scénario **synthétique** : 241 lignes reçues, 240 tickets uniques et 236 délais valides. Le contraste est **B − A** ; le gain utile de 5 minutes est un critère pédagogique fictif. Les conclusions doivent conserver incertitude et limites.

```r
# Pour vérifier le dépôt, pas pour valider vos propres TP :
source("tests/run_tests.R", encoding = "UTF-8")
source("tests/learner_checks.R", encoding = "UTF-8")
```

Le [workflow](.github/workflows/r-check.yml) vérifie R sur Ubuntu, Windows et macOS : [résultats dans Actions](https://github.com/jodouma/leaders-r-statistiques-18h/actions). La validation automatisée et les simulations de parcours ne mesurent pas la réussite de vrais débutants ni la durée réelle en classe.

`scripts/01_run_all.R` reproduit la référence complète, y compris modèle et agrégation locale. Il charge les réponses de référence et ne valide aucun TP étudiant. Les anciens exercices sont conservés dans `legacy/`. **Aucun environnement RHadoop réel n’est implémenté** ; l’adaptation du plan officiel reste à valider avec le coordinateur.

Les crédits des images, marques et polices sont dans [99_sources_visuelles.pdf](pdf/99_sources_visuelles.pdf).

Le guide coach et le document administratif source restent privés. Les fichiers JSON et Python de `authoring/` servent à fabriquer les PDF ; les étudiants n’ont pas besoin de Python.

Préparation : **Youssef Douma** · Leaders University · octobre 2026.

Pour reconstruire les supports (mainteneurs) : `python authoring/build_pdfs.py authoring/content.json --out pdf`, puis `python authoring/package_course.py`. Les dépendances sont dans `authoring/requirements.txt`.
