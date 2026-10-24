# Noria Gestion — lire les marchés avec R

Un playbook guidé pour des étudiants en finance : comprendre une méthode, lancer un **script complet et commenté**, observer ses résultats, puis modifier un paramètre. Le projet compare quatre indices historiques et construit un panier pédagogique CAC–DAX.

## Commencer sous Windows avec RStudio

1. **[Télécharger le cours en ZIP](https://github.com/jodouma/leaders-r-statistiques-18h/archive/refs/heads/main.zip)**, ou choisir **Code → Download ZIP**. Aucun compte GitHub ni Git n’est nécessaire.
2. Dans l’Explorateur Windows : clic droit sur le ZIP → **Extraire tout…**. Extraire cette édition dans **un nouveau dossier** ; conserver vos anciens essais séparément.
3. Ouvrir **[pdf/01_aventure_noria.pdf](pdf/01_aventure_noria.pdf)** : c’est le nouveau playbook finance. Son nom conserve le lien déjà distribué. Il explique l’installation facultative de R et RStudio, les fenêtres et chaque nouveau geste.
4. Double-cliquer **`course.Rproj`** dans le dossier extrait. Dans RStudio, ouvrir **`scripts/00_premiers_pas.R`**, puis suivre les blocs nommés **B01, B02…** du guide.

**[Télécharger le playbook principal](https://github.com/jodouma/leaders-r-statistiques-18h/raw/refs/heads/main/pdf/01_aventure_noria.pdf)**. Si l’aperçu GitHub gêne la lecture ou les liens, télécharger le PDF et l’ouvrir dans votre lecteur habituel. Les pages se suivent sans navigation obligatoire.

## Le parcours

| Étapes | Ce que vous faites |
|---|---|
| **00–06 · Le socle** | Lire et exécuter du R fourni ; calculer un pourcentage ; importer, contrôler et comparer les marchés |
| **07–09 · L’analyse** | Composer un panier ; expliquer VaR et drawdown ; tester un choc choisi |
| **10–12 · Facultatif** | Explorer une simulation, comparer un modèle et produire un rapport HTML local |

Le code est déjà prêt dans **`scripts/`**. Le PDF explique **quoi, pourquoi, quel bloc lancer, où regarder et quoi vérifier** ; il n’est pas un code à recopier. Sous Windows, **Run / Ctrl+Enter** lance une ligne ou une sélection complète. Commencer chaque nouveau script par **B01** ; il prépare ses propres entrées, même après un redémarrage de R.

| Guide | Utilisation |
|---|---|
| [01_aventure_noria.pdf](pdf/01_aventure_noria.pdf) | Le playbook finance complet ; commencer ici |
| [02_reperes_R.pdf](pdf/02_reperes_R.pdf) | Gestes, vocabulaire, unités et repères dans les scripts |
| [03_sources.pdf](pdf/03_sources.pdf) | Sources officielles, provenance des données et conventions |

**R de base ≥ 4.1 suffit ; aucun paquet supplémentaire.** Une fois les logiciels et le cours téléchargés, les analyses fonctionnent localement. Les résultats vont dans **`outputs/00/` à `outputs/12/`**. Le rapport final est **`outputs/12/rapport_noria.html`** ; garder son image voisine avec lui.

## Les données et le sens des résultats

**EuStockMarkets** contient **1 860 observations de 1991–1998**, sur DAX, SMI, CAC et FTSE. Le fichier d’entraînement ajoute volontairement **un doublon exact** et **une ligne incomplète** : **1 862 lignes brutes → 1 860 complètes et 1 isolée**, après dédoublonnage. Les **1 860 niveaux donnent 1 859 rendements** consécutifs.

L’identifiant `observation` conserve l’ordre des marchés ; il ne représente pas une date reconstituée. Ce sont des niveaux d’indices anciens, sans cotations actuelles. Le panier utilise des rendements locaux, se rééquilibre à chaque observation et exprime son capital en **UM** pédagogiques ; les séries d’indices sont utilisées telles quelles, sans traitement supplémentaire du change, des frais ou des dividendes. Les conventions des indices peuvent différer. La VaR est un seuil historique par observation de marché, le stress un scénario choisi, le bootstrap une simulation sous hypothèses et la régression une association contemporaine : leurs sorties demandent une interprétation, sans garantie sur le futur.

Pour repartir : **Ctrl+S → Session → Restart R → B01 du script courant**, puis ses blocs dans l’ordre. Garder les fichiers de `data/` intacts et noter le paramètre changé, l’effet observé et votre explication.

Youssef Douma · Leaders University · octobre 2026
