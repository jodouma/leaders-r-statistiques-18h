# Vérification du cours prêt à exécuter : Rscript tests/run_tests.R depuis le projet.
# Les essais travaillent dans des copies temporaires, sans anciens objets ni exports.
if (getRversion() < "4.1") stop("R 4.1 ou plus récent est nécessaire.")
if (!file.exists("course.Rproj") || !file.exists("R/outils.R")) stop("Ouvrez la racine du projet.")
root <- normalizePath(getwd(), winslash = "/")
r_executable <- commandArgs()[1]
if (!file.exists(r_executable)) stop("Exécutable R actif introuvable.")
workspace <- tempfile("noria-finance-tests-")
dir.create(workspace)
checks <- 0L
check <- function(label, condition) {
  if (!isTRUE(condition)) stop("ÉCHEC : ", label, call. = FALSE)
  checks <<- checks + 1L
  cat("OK —", label, "\n")
}
equal_num <- function(actual, expected, tolerance = 1e-9) {
  isTRUE(all.equal(as.numeric(actual), as.numeric(expected), tolerance = tolerance))
}
copy_project <- function(label) {
  target <- file.path(workspace, label)
  dir.create(target)
  paths <- c("course.Rproj", "R", "data", "scripts")
  if (!all(file.copy(file.path(root, paths), target, recursive = TRUE))) stop("Copie impossible.")
  target
}
run_child <- function(target, script) {
  previous <- getwd()
  on.exit(setwd(previous), add = TRUE)
  setwd(target)
  log <- tempfile(tmpdir = workspace)
  child_env <- character()
  if (Sys.info()[["sysname"]] == "Darwin" && nzchar(Sys.getenv("DYLD_LIBRARY_PATH")))
    child_env <- paste0("DYLD_LIBRARY_PATH=", shQuote(Sys.getenv("DYLD_LIBRARY_PATH")))
  status <- suppressWarnings(system2(r_executable,
    c("--vanilla", "--slave", paste0("--file=", shQuote(script))),
    stdout = log, stderr = log, env = child_env))
  output <- paste(readLines(log, warn = FALSE), collapse = "\n")
  if (status != 0L) cat(output, "\n")
  list(status = status, output = output)
}
read_output <- function(target, path) read.csv(file.path(target, "outputs", path))
expect_error <- function(expression) inherits(tryCatch(force(expression), error = identity), "error")
main <- function() {
  on.exit({setwd(root); unlink(workspace, recursive = TRUE)}, add = TRUE)
  source("R/outils.R")
  source_path <- c("data/marches_source.csv", "data/marches_brut.csv")
  before <- tools::md5sum(source_path)
  original <- read.csv(source_path[1])
  raw <- read.csv(source_path[2])
  official <- as.matrix(datasets::EuStockMarkets)
  check("CSV source fidèle aux 1860 x 4 valeurs réelles de R", nrow(original) == 1860 &&
        identical(original$observation, 1:1860) && equal_num(as.matrix(original[market_names]), official))
  # Comparaison des valeurs plutôt que des attributs de noms de lignes.
  check("La seule copie exacte reprend observation 100", sum(duplicated(raw)) == 1 &&
        equal_num(unlist(raw[1861, ]), unlist(original[100, ])))
  check("La ligne 1861 ajoutée est uniquement FTSE manquante", raw$observation[1862] == 1861 &&
        is.na(raw$FTSE[1862]) && sum(is.na(raw)) == 1 &&
        equal_num(unlist(raw[1862, c("DAX", "SMI", "CAC")]), unlist(original[1860, c("DAX", "SMI", "CAC")])))
  # Oracle indépendant : nettoyage, variations et composition sans les helpers du cours.
  unique_rows <- raw[!duplicated(raw), ]
  p <- unique_rows[complete.cases(unique_rows), ]
  p <- p[order(p$observation), ]
  expected_returns <- (as.matrix(p[-1, market_names]) - as.matrix(p[-nrow(p), market_names])) /
                      as.matrix(p[-nrow(p), market_names])
  portfolio <- 0.6 * expected_returns[, "CAC"] + 0.4 * expected_returns[, "DAX"]
  wealth <- numeric(length(portfolio) + 1L)
  wealth[1] <- 10000
  for (i in seq_along(portfolio)) wealth[i + 1] <- wealth[i] * (1 + portfolio[i])
  # Quantile type 7 calculé avec un tri et une interpolation explicites.
  ordered_losses <- sort(-portfolio)
  h <- 1 + (length(ordered_losses) - 1) * 0.95
  lower <- floor(h)
  expected_var <- 10000 * (ordered_losses[lower] + (h - lower) *
                          (ordered_losses[lower + 1] - ordered_losses[lower]))
  peak <- wealth[1]
  expected_drawdown <- 0
  for (value in wealth) {
    peak <- max(peak, value)
    expected_drawdown <- min(expected_drawdown, value / peak - 1)
  }
  scripts <- sort(list.files("scripts", pattern = "^[0-9]{2}_.+[.]R$"))
  check("Treize fichiers numérotés sans trous", length(scripts) == 13 &&
        identical(substr(scripts, 1, 2), sprintf("%02d", 0:12)))
  copies <- list()
  for (script in scripts) {
    target <- copy_project(substr(script, 1, 2))
    copies[[substr(script, 1, 2)]] <- target
    check(paste(script, "démarre sans outputs préexistants"), !dir.exists(file.path(target, "outputs")))
    result <- run_child(target, file.path("scripts", script))
    check(paste(script, "s'exécute seul dans R --vanilla"), result$status == 0)
    check(paste(script, "rend une auto-vérification sans quitter la session"),
          grepl("Observation cohérente", result$output, fixed = TRUE))
    check(paste(script, "préserve les CSV d'entrée"),
          identical(unname(tools::md5sum(file.path(target, source_path))), unname(before)))
    # Un second lancement extrait et exécute les blocs fournis en ordre, sans source(script).
    lines <- readLines(file.path(target, "scripts", script), warn = FALSE)
    markers <- grep("^# B[0-9]{2} .*----$", lines)
    check(paste(script, "contient B01 puis des blocs contigus"),
          length(markers) >= 4 && identical(substr(lines[markers], 3, 5), sprintf("B%02d", seq_along(markers))))
    # Ce wrapper explicite les frontières de blocs comme une sélection RStudio successive.
    wrapper <- c(sprintf("lines <- readLines(%s, warn=FALSE)", dQuote(file.path("scripts", script), q = FALSE)),
                 "markers <- grep('^# B[0-9]{2} .*----$', lines)",
                 "ends <- c(markers[-1]-1L,length(lines))",
                 "for(i in seq_along(markers)) eval(parse(text=lines[markers[i]:ends[i]]),envir=.GlobalEnv)",
                 "cat('SESSION_PRESERVEE\\n')")
    writeLines(wrapper, file.path(target, "blocks.R"))
    block_run <- run_child(target, "blocks.R")
    check(paste(script, "blocs sélectionnés exécutables en ordre"),
          block_run$status == 0 && grepl("SESSION_PRESERVEE", block_run$output, fixed = TRUE))
  }
  check("Petit calcul : 500 UM et 10500 UM", equal_num(read_output(copies[['01']], "01/capital.csv")$gain_UM, 500) &&
        equal_num(read_output(copies[['01']], "01/capital.csv")$first_final_UM, 10500))
  check("Composition +5 puis -5 : 9975 UM", equal_num(read_output(copies[['01']], "01/capital.csv")$compounded_final_UM, 9975))
  counts <- read_output(copies[['03']], "03/controle.csv")
  check("Nettoyage 1862 → 1861 → 1860 + 1", identical(counts$rows, c(1862L, 1861L, 1860L, 1L)))
  observed_returns <- read_output(copies[['04']], "04/rendements.csv")
  check("1859 rendements : oracle formule différence/niveau précédent", nrow(observed_returns) == 1859 &&
        equal_num(as.matrix(observed_returns[market_names]), expected_returns))
  statistics <- read_output(copies[['05']], "05/statistiques.csv")
  check("Statistiques calculées sur les vrais rendements CAC", equal_num(unlist(statistics[c('mean_percent','median_percent','sd_percent','min_percent','max_percent')]),
        100 * c(mean(expected_returns[, 'CAC']), median(expected_returns[, 'CAC']), sd(expected_returns[, 'CAC']), min(expected_returns[, 'CAC']), max(expected_returns[, 'CAC']))))
  normalized <- read_output(copies[['06']], "06/indices_base100.csv")
  check("Base100 : première et dernière lignes indépendantes", equal_num(unlist(normalized[1, market_names]), rep(100, 4)) &&
        equal_num(unlist(normalized[nrow(normalized), market_names]), 100 * official[1860, ] / official[1, ]))
  check("Capital composé : oracle multiplication séquentielle", equal_num(read_output(copies[['07']], "07/capital_panier.csv")$capital_UM, wealth))
  risk <- read_output(copies[['08']], "08/risque.csv")
  check("VaR : oracle tri/interpolation type7", equal_num(risk$historical_VaR_UM, expected_var))
  check("Drawdown : oracle sommet courant avec capital initial", equal_num(risk$maximum_drawdown, expected_drawdown))
  check("Petit chemin -10%, +10% inclut bien sa perte initiale", equal_num(risk_summary(c(-0.1, 0.1))$maximum_drawdown, -0.1))
  shock <- read_output(copies[['09']], "09/choc.csv")
  check("Choc inventé : -6% puis 9400 UM", equal_num(shock$scenario_return, -0.06) && equal_num(shock$final_capital_UM, 9400))
  set.seed(2026)
  draws <- sample(portfolio, 20 * 5000, replace = TRUE)
  simulated <- vapply(seq_len(5000), function(j) {
    value <- 10000
    for (r in draws[((j - 1) * 20 + 1):(j * 20)]) value <- value * (1 + r)
    value
  }, numeric(1))
  actual_simulated <- read_output(copies[['10']], "10/scenarios.csv")$final_capital_UM
  check("Simulation : oracle boucles, 5000 chemins et graine 2026", length(actual_simulated) == 5000 && equal_num(actual_simulated, simulated))
  repeat_run <- run_child(copies[['10']], file.path("scripts", scripts[11]))
  check("Simulation reproductible dans un autre processus vierge", repeat_run$status == 0 &&
        identical(actual_simulated, read_output(copies[['10']], "10/scenarios.csv")$final_capital_UM))
  ntrain <- floor(nrow(expected_returns) * 0.8)
  xtrain <- expected_returns[seq_len(ntrain), 'DAX']; ytrain <- expected_returns[seq_len(ntrain), 'CAC']
  xtest <- expected_returns[(ntrain + 1):nrow(expected_returns), 'DAX']
  ytest <- expected_returns[(ntrain + 1):nrow(expected_returns), 'CAC']
  slope <- sum((xtrain - mean(xtrain)) * (ytrain - mean(ytrain))) / sum((xtrain - mean(xtrain))^2)
  intercept <- mean(ytrain) - slope * mean(xtrain)
  oracle_rmse <- c(sqrt(mean((ytest - (intercept + slope * xtest))^2)), sqrt(mean((ytest - mean(ytrain))^2)))
  check("Régression : oracle OLS fermé et baseline entraînement", equal_num(read_output(copies[['11']], "11/erreurs_test.csv")$test_RMSE_percent, 100 * oracle_rmse))
  estimated <- read_output(copies[['11']], "11/estimations_test.csv")
  check("Découpage chronologique 1487/372 sans fuite", ntrain == 1487 && nrow(estimated) == 372 && min(estimated$observation) == 1489)
  check("Rapport final + image relative existent dans la copie vierge", file.exists(file.path(copies[['12']], 'outputs/12/rapport_noria.html')) &&
        file.exists(file.path(copies[['12']], 'outputs/12/comparaison_paniers.png')))
  html <- paste(readLines(file.path(copies[['12']], 'outputs/12/rapport_noria.html'), warn=FALSE), collapse=' ')
  check("Rapport porte les limites financières et les unités", all(vapply(c('UM', 'change', 'dividendes', 'rééquilibré', '1991–1998', 'garantie'), grepl, logical(1), x=html, fixed=TRUE)))
  # Nouvelles valeurs/longueur : la fonction ne peut répondre avec des nombres fixes.
  alternate <- copies[['12']]
  tiny <- data.frame(observation = 1:4, DAX = c(100,110,99,108.9), SMI = c(200,204,202,208),
                     CAC = c(100,102,104.04,106.1208), FTSE = c(300,303,300,306))
  write.csv(tiny, file.path(alternate, 'data/nouveau.csv'), row.names=FALSE)
  writeLines(c("source('scripts/12_automatiser_le_rapport.R')",
    "new <- analyze_basket('data/nouveau.csv',0.25,2000)",
    "write.csv(new,'new.csv',row.names=FALSE)"), file.path(alternate, 'alternate.R'))
  check("Automatisation accepte un autre CSV et d'autres paramètres", run_child(alternate,'alternate.R')$status == 0)
  new <- read.csv(file.path(alternate, 'new.csv'))
  tiny_return <- 0.25 * rep(0.02,3) + 0.75 * c(0.1,-0.1,0.1)
  check("Nouveau CSV : oracle 3 variations, nouveaux poids/capital", new$observations == 3 &&
        equal_num(new$final_capital_UM, 2000 * prod(1 + tiny_return)) &&
        equal_num(new$historical_VaR_UM, 2000 * (sort(-tiny_return)[2] + 0.9 * diff(sort(-tiny_return)[2:3]))))
  # Une variation de paramètre légitime ne déclenche pas un faux verdict d'échec.
  experiments <- list(c('01','rate <- 0.05','rate <- 0.10','01/capital.csv','gain_UM','1000'),
                      c('07','cac_weight <- 0.60','cac_weight <- 0.80','07/capital_panier.csv','capital_UM',''),
                      c('08','confidence <- 0.95','confidence <- 0.99','08/risque.csv','confidence','0.99'),
                      c('10','horizon <- 20','horizon <- 40','10/scenarios.csv','final_capital_UM',''),
                      c('11','train_fraction <- 0.80','train_fraction <- 0.70','11/estimations_test.csv','actual_CAC',''))
  for (experiment in experiments) {
    target <- copy_project(paste0('experiment-',experiment[1]))
    script <- scripts[as.integer(experiment[1])+1]
    lines <- readLines(file.path(target,'scripts',script),warn=FALSE)
    check(paste('Paramètre présent',experiment[1]), sum(grepl(experiment[2],lines,fixed=TRUE)) == 1)
    lines <- sub(experiment[2],experiment[3],lines,fixed=TRUE)
    writeLines(lines,file.path(target,'scripts',script))
    result <- run_child(target,file.path('scripts',script))
    check(paste('Variation valide',experiment[1]),result$status == 0 && grepl('Observation cohérente',result$output,fixed=TRUE))
    if(nzchar(experiment[6])) check(paste('Valeur modifiée',experiment[1]),
      equal_num(read_output(target,experiment[4])[[experiment[5]]],as.numeric(experiment[6])))
  }
  invalid_parameters <- list(c('07','capital <- 10000','capital <- -100'),
                             c('08','confidence <- 0.95','confidence <- 1'),
                             c('10','horizon <- 20','horizon <- 2.5'),
                             c('11','train_fraction <- 0.80','train_fraction <- 1.2'))
  for (variant in invalid_parameters) {
    target <- copy_project(paste0('invalid-',variant[1]))
    script <- scripts[as.integer(variant[1])+1]
    lines <- readLines(file.path(target,'scripts',script),warn=FALSE)
    writeLines(sub(variant[2],variant[3],lines,fixed=TRUE),file.path(target,'scripts',script))
    check(paste('Paramètre invalide refusé avec message',variant[1]),
          run_child(target,file.path('scripts',script))$status != 0)
  }
  reconstruction <- copy_project('reconstruction')
  file.copy(file.path(root,'authoring/exporter_donnees.R'),file.path(reconstruction,'export.R'))
  check('Reconstruction auteur exécutable sans écrire data/',run_child(reconstruction,'export.R')$status == 0)
  rebuilt <- tools::md5sum(file.path(reconstruction,'outputs/reconstruction_source',basename(source_path)))
  check('Reconstruction exacte et sources préservées',identical(unname(rebuilt),unname(before)) &&
        identical(unname(tools::md5sum(file.path(reconstruction,source_path))),unname(before)))
  # Le tableau affiché doit venir du CSV enregistré, même si un objet a changé.
  summary <- data.frame(final_capital_UM = -999)
  readback <- inspect_export(file.path(copies[['00']], 'outputs', '00'), 'premier_calcul.csv')
  check('Lecture automatique du vrai CSV, sans utiliser un ancien objet',
        equal_num(readback$final_capital_UM,10500) && equal_num(readback$gain_UM,500))
  check('CSV absent : reprise explicite au lieu de montrer un ancien tableau',
        expect_error(inspect_export(workspace,'fichier_absent.csv')))
  corrupted <- copy_project('corrupted')
  bad <- tiny; bad$DAX[1] <- -1
  write.csv(bad,file.path(corrupted,'data/marches_brut.csv'),row.names=FALSE)
  check("Prix non positif refusé",run_child(corrupted,file.path('scripts',scripts[5]))$status != 0)
  bad <- tiny; names(bad)[2] <- 'inconnue'
  write.csv(bad,file.path(corrupted,'data/marches_brut.csv'),row.names=FALSE)
  check("Mauvaise colonne refusée",run_child(corrupted,file.path('scripts',scripts[3]))$status != 0)
  bad <- rbind(tiny,tiny[2,]); bad$CAC[5] <- 999
  write.csv(bad,file.path(corrupted,'data/marches_brut.csv'),row.names=FALSE)
  check("Identifiant contradictoire refusé",run_child(corrupted,file.path('scripts',scripts[4]))$status != 0)
  bad <- tiny; bad$DAX[1] <- Inf
  write.csv(bad,file.path(corrupted,'data/marches_brut.csv'),row.names=FALSE)
  check("Niveau infini refusé",run_child(corrupted,file.path('scripts',scripts[5]))$status != 0)
  bad <- tiny; bad$observation[1] <- NA
  write.csv(bad,file.path(corrupted,'data/marches_brut.csv'),row.names=FALSE)
  check("Observation manquante refusée",run_child(corrupted,file.path('scripts',scripts[5]))$status != 0)
  # Une absence interne ne doit pas devenir silencieusement un rendement de plusieurs périodes.
  gap <- data.frame(observation = 1:4, DAX = c(100,110,121,133.1),
                    SMI = c(100,110,121,133.1), CAC = c(100,110,121,133.1),
                    FTSE = c(100,NA,121,133.1))
  gap_clean <- clean_markets(gap)
  check("Quarantaine interne conservée pour inspection",nrow(gap_clean$quarantine)==1)
  check("Helper refuse les rendements de durées mélangées",expect_error(make_returns(gap_clean$prices)))
  write.csv(gap,file.path(corrupted,'data/marches_brut.csv'),row.names=FALSE)
  check("Calcul visible du script04 refuse aussi une absence interne",
        run_child(corrupted,file.path('scripts',scripts[5]))$status != 0)
  check("Rapport réutilisable refuse aussi une absence interne",
        run_child(corrupted,file.path('scripts',scripts[13]))$status != 0)
  check("Poids hors intervalle refusé",expect_error(basket_returns(data.frame(CAC=.01,DAX=.02),1.1)))
  check("Confiance hors intervalle refusée",expect_error(risk_summary(c(.1,-.1),confidence=1)))
  wrong <- file.path(workspace,'wrong-root'); dir.create(wrong)
  wrong_run <- run_child(wrong,file.path(root,'scripts',scripts[1]))
  check("Mauvaise racine : message français et récupération File > Open Project", wrong_run$status != 0 &&
        grepl('File > Open Project',wrong_run$output,fixed=TRUE))
  # Une session Source peut contenir d'anciens objets : le script repart de son CSV.
  preserved <- copy_project('stale-memory')
  writeLines(c("portfolio <- rep(999,1859); wealth <- rep(1,1860)",
    "source('scripts/07_composer_un_portefeuille.R')", "cat('SESSION_PRESERVEE\\n')"),file.path(preserved,'stale.R'))
  old_run <- run_child(preserved,'stale.R')
  check("Mémoire ancienne ignorée et session Source préservée",old_run$status == 0 &&
        grepl('SESSION_PRESERVEE',old_run$output,fixed=TRUE) &&
        equal_num(read_output(preserved,'07/capital_panier.csv')$capital_UM,wealth))
  check("Tests et essais ne modifient aucun CSV original",identical(tools::md5sum(source_path),before))
  cat(checks, "vérifications réussies ; 13 scripts, 13 copies sans outputs, nouveaux processus et oracles indépendants.\n")
}
main()
