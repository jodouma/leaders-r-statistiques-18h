# Verification publique du contrat. Depuis la racine : Rscript tests/run_tests.R
# R >= 4.1, distribution standard uniquement. Aucun package a installer.
if (getRversion() < "4.1") stop("R 4.1 ou plus recent est necessaire.")
if (!file.exists("data/orders_raw.csv") || !file.exists("checks/check_tools.R")) {
  stop("Lancez ce fichier depuis la racine du dossier du cours.")
}
root <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
# commandArgs()[1] est l'executable R actif, y compris derriere Rscript.
# Aucune installation particuliere ou adresse absolue n'est codee dans les tests.
r_executable <- commandArgs()[1]
if (!file.exists(r_executable)) stop("Executable R actif introuvable : ", r_executable)
r_executable <- normalizePath(r_executable, winslash = "/", mustWork = TRUE)
stems <- c("01_panier", "02_semaine", "03_importer", "04_nettoyer",
           "05_analyser", "06_visualiser", "07_decider", "08_automatiser")
workspace <- tempfile("noria-tests-")
dir.create(workspace)
results <- list()

record <- function(label, ok, detail = "") {
  results[[length(results) + 1L]] <<- list(label=label, ok=isTRUE(ok), detail=detail)
  if (!isTRUE(ok)) cat("ECHEC :", label, "\n", detail, "\n")
  invisible(ok)
}
make_copy <- function(label) {
  destination <- file.path(workspace, label)
  dir.create(destination)
  paths <- c("data", "missions", "solutions", "examples", "checks",
             "00_verifier_installation.R")
  copied <- file.copy(file.path(root, paths), destination, recursive=TRUE)
  if (!all(copied)) stop("Impossible de creer une copie isolee pour : ", label)
  dir.create(file.path(destination, "outputs"))
  destination
}
run_r <- function(directory, script, args=character()) {
  previous_directory <- getwd()
  on.exit(setwd(previous_directory), add=TRUE)
  setwd(directory)
  log_path <- tempfile("r-log-", tmpdir=workspace)
  # macOS peut nettoyer DYLD_LIBRARY_PATH a l'entree du shell utilise par system2.
  # Conserver le reglage deja fourni par l'installation active, sans chemin impose.
  child_env <- character()
  if (Sys.info()[["sysname"]] == "Darwin" && nzchar(Sys.getenv("DYLD_LIBRARY_PATH"))) {
    child_env <- paste0("DYLD_LIBRARY_PATH=", shQuote(Sys.getenv("DYLD_LIBRARY_PATH")))
  }
  status <- suppressWarnings(system2(r_executable,
    args=c("--vanilla", "--slave", paste0("--file=", shQuote(script)),
           "--args", shQuote(args)), stdout=log_path, stderr=log_path, env=child_env))
  text <- if (file.exists(log_path)) paste(readLines(log_path, warn=FALSE),collapse="\n") else ""
  unlink(log_path)
  list(status=as.integer(status), output=text)
}
expect_run <- function(label, directory, script, args=character(), succeeds=TRUE) {
  actual <- run_r(directory, script, args)
  record(label, (actual$status == 0L) == succeeds, actual$output)
  invisible(actual)
}
write_script <- function(directory, name, lines) {
  path <- file.path(directory, name)
  writeLines(lines, path, useBytes=TRUE)
  name
}
num_equal <- function(x, y) isTRUE(all.equal(as.numeric(x), as.numeric(y), tolerance=1e-8))

main <- function() {
  on.exit({setwd(root); unlink(workspace, recursive=TRUE)}, add=TRUE)
  # Distinguer une panne de lancement R d'un starter refuse par son controle.
  smoke <- make_copy("runtime")
  write_script(smoke,"runtime.R","stopifnot(getRversion() >= '4.1')")
  smoke_result <- run_r(smoke,"runtime.R")
  if (smoke_result$status != 0L) stop("Impossible de lancer R enfant : ",smoke_result$output)
  # Faits du carnet, independants de la forme des scripts des apprenants.
  raw <- read.csv(file.path(root,"data/orders_raw.csv"), stringsAsFactors=FALSE)
  reference <- read.csv(file.path(root,"data/orders_clean_reference.csv"), stringsAsFactors=FALSE)
  mini <- read.csv(file.path(root,"data/orders_mini.csv"), stringsAsFactors=FALSE)
  second <- read.csv(file.path(root,"data/orders_week2_raw.csv"), stringsAsFactors=FALSE)
  complete <- unique(raw)
  waiting <- complete[is.na(complete$quantite), ]
  complete <- complete[!is.na(complete$quantite), ]
  record("six colonnes contractuelles", identical(names(raw),
    c("id","date","produit","quantite","prix_unitaire","cout_unitaire")))
  record("14 lignes, une copie exacte O004, une quantite O013 inconnue",
    nrow(raw)==14 && sum(duplicated(raw))==1 &&
    identical(raw$id[duplicated(raw)],"O004") && nrow(waiting)==1 && waiting$id=="O013")
  record("12 commandes propres, quantites connues, reference fidele",
    nrow(complete)==12 && !anyNA(complete) &&
    identical(complete$id,reference$id) &&
    isTRUE(all.equal(complete,reference,check.attributes=FALSE)))
  record("21 unites, 100 TND de recettes, 37 TND de cout, 63 TND de marge",
    sum(complete$quantite)==21 &&
    sum(complete$quantite*complete$prix_unitaire)==100 &&
    sum(complete$quantite*complete$cout_unitaire)==37 &&
    sum(complete$quantite*(complete$prix_unitaire-complete$cout_unitaire))==63)
  day_ca <- tapply(complete$quantite*complete$prix_unitaire,complete$date,sum)
  product_ca <- tapply(complete$quantite*complete$prix_unitaire,complete$produit,sum)
  record("quatre jours : 19, 27, 33 et 21 TND",num_equal(day_ca,c(19,27,33,21)))
  record("Cafe 30, Sandwich 40, The 30 TND",num_equal(product_ca,c(30,40,30)))
  record("mini-carnet : trois premieres commandes, panier 19 TND",
    nrow(mini)==3 && identical(mini$id,raw$id[1:3]) &&
    sum(mini$quantite*mini$prix_unitaire)==19)
  second_complete <- unique(second)
  second_complete <- second_complete[!is.na(second_complete$quantite), ]
  record("nouveau carnet : 8 lignes, 6 completes, 9 unites, 48/18/30 TND",
    nrow(second)==8 && nrow(second_complete)==6 &&
    sum(second_complete$quantite)==9 &&
    sum(second_complete$quantite*second_complete$prix_unitaire)==48 &&
    sum(second_complete$quantite*second_complete$cout_unitaire)==18 &&
    sum(second_complete$quantite*(second_complete$prix_unitaire-second_complete$cout_unitaire))==30)

  setup_copy <- make_copy("setup")
  expect_run("installation : copie complete",setup_copy,"00_verifier_installation.R")
  unlink(file.path(setup_copy,"missions/08_automatiser.R"))
  expect_run("installation refuse une copie incomplete",setup_copy,"00_verifier_installation.R",succeeds=FALSE)
  for (stem in stems) {
    isolated <- make_copy(paste0(stem,"-solution"))
    expect_run(paste(stem,"corrige executable seul"), isolated,
               paste0("solutions/",stem,"_solution.R"))
    expect_run(paste(stem,"corrige valide par son controle"), isolated,
               paste0("checks/",stem,".R"), paste0("solutions/",stem,"_solution.R"))
    starter_copy <- make_copy(paste0(stem,"-starter"))
    expect_run(paste(stem,"starter vierge refuse"),starter_copy,
               paste0("checks/",stem,".R"),succeeds=FALSE)
    example_copy <- make_copy(paste0(stem,"-exemple"))
    expect_run(paste(stem,"exemple executable seul"),example_copy,
               paste0("examples/",stem,"_exemple.R"))
  }
  cumulative <- make_copy("parcours-complet")
  for (stem in stems) {
    expect_run(paste(stem,"execution cumulative avec exports precedents"),cumulative,
               paste0("solutions/",stem,"_solution.R"))
  }

  # Le CSV propre de mission 4 est un input legitime pour les missions 5 a 7.
  # Un script correct peut le lire directement, sans recopier le secours fourni.
  for (stem in stems[5:7]) {
    direct <- make_copy(paste0(stem,"-lecture-directe"))
    expect_run(paste(stem,"preparer son input legitime de mission 4"),direct,
               "solutions/04_nettoyer_solution.R")
    solution_lines <- readLines(file.path(direct,"solutions",paste0(stem,"_solution.R")),warn=FALSE)
    # Conserver le calcul de l'apprenant, remplacer seulement le bloc d'entree.
    start <- grep("^propres <- read.csv",solution_lines)[1]
    direct_lines <- c("propres <- read.csv('outputs/04_commandes_propres.csv',stringsAsFactors=FALSE)",
                       solution_lines[seq.int(start+1L,length(solution_lines))])
    write_script(direct,"lecture_directe.R",direct_lines)
    expect_run(paste(stem,"lecture directe de son CSV propre acceptee"),direct,
               paste0("checks/",stem,".R"),"lecture_directe.R")
    corrupt_lines <- c("x <- read.csv('outputs/04_commandes_propres.csv',stringsAsFactors=FALSE)",
                       "x$quantite[1] <- 99", "write.csv(x,'outputs/04_commandes_propres.csv',row.names=FALSE)")
    write_script(direct,"corrompre.R",corrupt_lines)
    expect_run(paste(stem,"modifier input pour tester le controle"),direct,"corrompre.R")
    expect_run(paste(stem,"input corrompu refuse sans remplacement silencieux"),direct,
               paste0("checks/",stem,".R"),"lecture_directe.R",succeeds=FALSE)

    old_answers <- make_copy(paste0(stem,"-anciens-resultats"))
    write_script(old_answers,"console.R",c(
      "source('solutions/04_nettoyer_solution.R')",
      paste0("source('solutions/",stem,"_solution.R')"),
      paste0("source('checks/",stem,".R')"), "stopifnot(!controle$ok)"))
    expect_run(paste(stem,"ancien resultat refuse meme avec input legitime"),old_answers,"console.R")
  }

  # Equivalent mathematique : le controle ne compare pas le texte du code.
  alternative <- make_copy("variante-valide")
  write_script(alternative,"variante.R",c(
    "prix_cafe=3;quantite_cafe=2;prix_the=5;quantite_the=1;prix_sandwich=8;quantite_sandwich=1",
    "total_panier=sum(c(6,5,8));cout_panier=sum(c(2,2,3));marge_panier=sum(c(4,3,5))"))
  expect_run("calcul equivalent accepte",alternative,"checks/01_panier.R","variante.R")
  perturbation <- make_copy("perturbation-tolerable")
  original <- readLines(file.path(perturbation,"solutions/01_panier_solution.R"),warn=FALSE)
  write_script(perturbation,"variante.R",c(original,
    "total_panier <- total_panier + 1e-10", "marge_panier <- marge_panier - 1e-10"))
  expect_run("difference numerique negligeable acceptee",perturbation,"checks/01_panier.R","variante.R")

  # M8 doit travailler sur un nouveau chemin et de nouvelles valeurs.
  fixed <- make_copy("fonction-a-nombres-fixes")
  original <- readLines(file.path(fixed,"solutions/08_automatiser_solution.R"),warn=FALSE)
  write_script(fixed,"fausse_fonction.R",c(original,
    "resumer_commandes <- function(chemin) resultat_semaine_2"))
  expect_run("fonction a nombres fixes refusee",fixed,"checks/08_automatiser.R",
             "fausse_fonction.R",succeeds=FALSE)
  general <- make_copy("fonction-nouvelles-valeurs")
  write_script(general,"nouveau_carnet.R",c(
    "source('solutions/08_automatiser_solution.R')",
    "nouveau <- data.frame(id=c('X1','X2','X1','X3'),date='2026-10-22',produit=c('Cafe','The','Cafe','Sandwich'),quantite=c(5,3,5,NA),prix_unitaire=c(4,6,4,9),cout_unitaire=c(2,1,2,4))",
    "write.csv(nouveau,'data/nouveau.csv',row.names=FALSE)",
    "r <- resumer_commandes('data/nouveau.csv')",
    "stopifnot(nrow(r)==1,r$chiffre_affaires==38,r$cout_total==13,r$marge==25,r$quantite==8,r$n_commandes==2)"))
  expect_run("fonction accepte un carnet avec prix et quantites modifies",general,"nouveau_carnet.R")

  console <- make_copy("console")
  write_script(console,"console.R",c(
    "avant_dossier <- getwd()",
    "png(tempfile(fileext='.png')); avant_appareil <- dev.cur()",
    "source('checks/01_panier.R')",
    "stopifnot(exists('controle'),!controle$ok,controle$score==0)",
    "stopifnot(getwd()==avant_dossier,dev.cur()==avant_appareil)",
    "dev.off()", "cat('SESSION_PRESERVEE\\n')"))
  expect_run("source preserve session, dossier et ancien appareil",console,"console.R")
  expect_run("source ignore les arguments du processus appelant",console,"console.R",
             args="ce-chemin-nexiste-pas.R")

  no_inherit <- make_copy("sans-heritage-console")
  write_script(no_inherit,"missions/01_panier.R",c(
    "prix_cafe=3;quantite_cafe=2;prix_the=5;quantite_the=1;prix_sandwich=8;quantite_sandwich=1",
    "total_panier <- oubli_console;cout_panier <- 7;marge_panier <- 12"))
  write_script(no_inherit,"console.R",c(
    "oubli_console <- 19", "source('checks/01_panier.R')",
    "stopifnot(!controle$ok,controle$score==0)"))
  expect_run("les objets precedents de Console ne donnent pas de points",no_inherit,"console.R")

  stale <- make_copy("sans-anciens-exports")
  write_script(stale,"console.R",c(
    "source('solutions/06_visualiser_solution.R')",
    "source('checks/06_visualiser.R')", "stopifnot(!controle$ok,controle$score<3)"))
  expect_run("les anciens graphiques ne donnent pas de points au starter",stale,"console.R")

  failed <- vapply(results,function(x)!x$ok,logical(1))
  cat(sum(!failed), "/",length(results)," verifications reussies.\n",sep="")
  if (any(failed)) stop(sum(failed)," verification(s) en echec.",call.=FALSE)
  invisible(TRUE)
}
main()
