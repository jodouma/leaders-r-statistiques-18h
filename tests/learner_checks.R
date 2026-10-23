# Contrats du parcours étudiant : sorties réelles et erreurs ciblées, sans charger R/.
# Depuis la racine : Rscript tests/learner_checks.R
# Chaque cas utilise un dossier temporaire et un environnement sans objets globaux.
run_learner_checks <- function() {
  project <- normalizePath(".", mustWork = TRUE)
  if (!file.exists(file.path(project, "data", "noria_dirty.csv"))) {
    stop("Exécuter tests/learner_checks.R depuis la racine du projet.")
  }
  specs <- data.frame(
    tp = c("01", "02", "03", "04"),
    nom = c("demarrer", "preparer", "comparer", "projet"),
    objet = c("durees", "raw", "clean", "raw4"),
    erreur_vide = c("n_total", "compter séparément", "extraire les deux groupes", "audit : cinq colonnes"),
    sortie = c("TP01_resume.csv", "TP02_clean.csv", "TP03_comparaison.csv", "TP04_comparaison.csv"),
    stringsAsFactors = FALSE)
  files <- c(
    paste0("labs/TP", specs$tp, "_", specs$nom, ".R"),
    paste0("solutions/TP", specs$tp, "_", specs$nom, "_solution.R"),
    paste0("checks/TP", specs$tp, ".R"), "checks/_utils.R",
    "data/noria_dirty.csv", "data/noria_clean_reprise.csv",
    "examples/mini_welch.R", "examples/mini_note_pdf.R", "examples/mini_structures.R")
  expect_error_matching <- function(expr, pattern) {
    err <- tryCatch({ force(expr); NULL }, error = identity)
    if (!inherits(err, "error")) stop("Le contrôle aurait dû refuser ce cas : ", pattern)
    if (!grepl(pattern, conditionMessage(err), fixed = TRUE)) {
      stop("Échec pour une mauvaise raison : ", conditionMessage(err), " ; attendu : ", pattern)
    }
    invisible(err)
  }
  # Les paquets R de base restent accessibles ; .GlobalEnv est exclu de la chaîne.
  new_student_env <- function() new.env(parent = as.environment("package:stats"))
  no_reference_helpers <- function(e) {
    helpers <- c("read_noria", "clean_noria", "compare_workflows", "run_pipeline", "validate_analysis")
    if (any(vapply(helpers, exists, logical(1), envir = e, inherits = FALSE))) {
      stop("Un contrôle a préchargé des fonctions du pipeline de référence.")
    }
  }
  source_quiet <- function(path, e) {
    invisible(capture.output(source(path, local = e, encoding = "UTF-8")))
  }
  count <- 0L
  in_case <- function(label, action) {
    folder <- tempfile("r-learner-checks-")
    dir.create(folder)
    for (path in files) {
      target <- file.path(folder, path)
      dir.create(dirname(target), recursive = TRUE, showWarnings = FALSE)
      if (!file.copy(file.path(project, path), target)) stop("Copie impossible : ", path)
    }
    oldwd <- setwd(folder)
    on.exit({ setwd(oldwd); unlink(folder, recursive = TRUE) }, add = TRUE)
    # Aucun dossier R/ et aucun résultat antérieur : une dépendance cachée doit échouer.
    stopifnot(!dir.exists("R"), !dir.exists("results"))
    action()
    count <<- count + 1L
    message("OK : ", label)
  }
  for (i in seq_len(nrow(specs))) {
    s <- specs[i, ]
    solution <- paste0("solutions/TP", s$tp, "_", s$nom, "_solution.R")
    lab <- paste0("labs/TP", s$tp, "_", s$nom, ".R")
    check <- paste0("checks/TP", s$tp, ".R")
    in_case(paste0("TP", s$tp, " corrigé autonome puis sortie manquante refusée"), function() {
      e <- new_student_env()
      source_quiet(solution, e)
      source_quiet(check, e) # Ne dépend pas du contrôle intégré au corrigé.
      no_reference_helpers(e)
      if (s$tp == "03") stopifnot(isTRUE(e$mode_reprise))
      output <- file.path("results", s$sortie)
      stopifnot(file.exists(output))
      # Enlever un livrable réel doit invalider des objets pourtant corrects.
      bytes <- readBin(output, what = "raw", n = file.info(output)$size)
      unlink(output)
      expect_error_matching(source_quiet(check, e), s$sortie)
      writeBin(bytes, output)
      if (s$tp == "04") {
        stopifnot(inherits(e$session4, "sessionInfo"))
        unlink("results/TP04_sessionInfo.txt")
        expect_error_matching(source_quiet(check, e), "exporter session4")
      }
    })
    in_case(paste0("TP", s$tp, " fichier de départ refusé"), function() {
      e <- new_student_env()
      source_quiet(lab, e)
      expect_error_matching(source_quiet(check, e), s$erreur_vide)
      no_reference_helpers(e)
    })
    in_case(paste0("TP", s$tp, " contrôle seul sans réponse préchargée"), function() {
      e <- new_student_env()
      expect_error_matching(source_quiet(check, e), paste("créer l'objet", s$objet))
      no_reference_helpers(e)
      stopifnot(!exists(s$objet, envir = e, inherits = FALSE))
      stopifnot(!dir.exists("results"))
    })
  }
  in_case("TP02 : résumé correct présenté en data.frame accepté", function() {
    e <- new_student_env()
    source_quiet("solutions/TP02_preparer_solution.R", e)
    original <- e$resumer_durees
    e$resumer_durees <- function(x) as.data.frame(as.list(original(x)))
    source_quiet("checks/TP02.R", e)
  })
  in_case("exemple structures : retirer le nom du quantile avant de nommer q1", function() {
    e <- new_student_env()
    source_quiet("examples/mini_structures.R", e)
    stopifnot(identical(names(e$q), "25%"), unname(e$q) == 15,
              identical(names(e$quartile_avec_nom), "q1.25%"),
              identical(names(e$quartile_sans_nom), "q1"),
              identical(unname(e$quartile_avec_nom), unname(e$quartile_sans_nom)))
    ligne <- data.frame(workflow = "A", as.list(e$quartile_sans_nom))
    stopifnot(identical(names(ligne), c("workflow", "q1")), ligne$q1 == 15)
  })
  # Régression critique : un ID identique avec un contenu différent ne peut être dédupliqué.
  for (tp in c("02", "04")) {
    in_case(paste0("TP", tp, " doublon conflictuel refusé avant export"), function() {
      bad <- read.csv("data/noria_dirty.csv", na.strings = c("", "NA"), stringsAsFactors = FALSE)
      repeat_row <- which(bad$ticket_id == 17)[2]
      bad$resolution_minutes[repeat_row] <- bad$resolution_minutes[repeat_row] + 1
      write.csv(bad, "data/noria_dirty.csv", row.names = FALSE)
      s <- specs[specs$tp == tp, ]
      solution <- paste0("solutions/TP", tp, "_", s$nom, "_solution.R")
      expect_error_matching(source_quiet(solution, new_student_env()), "Doublon conflictuel")
      stopifnot(!dir.exists("results"))
    })
  }
  in_case("exemple Welch : contraste jouet et vrai PDF d'une page", function() {
    e <- new_student_env()
    source_quiet("examples/mini_welch.R", e)
    stopifnot(e$delta_mini == -2, e$ic_mini[1] < 0, e$ic_mini[2] > 0)
    pdf_bytes <- readBin("results/mini_welch_ic.pdf", "raw", n = file.info("results/mini_welch_ic.pdf")$size)
    pdf_text <- paste(rawToChar(pdf_bytes, multiple = TRUE), collapse = "")
    stopifnot(identical(rawToChar(pdf_bytes[1:5]), "%PDF-"))
    pages <- gregexpr("/Type /Page\\b", pdf_text, perl = TRUE, useBytes = TRUE)[[1]]
    stopifnot(pages[1] > 0, length(pages) == 1L)
    stopifnot(!exists("clean", envir = e, inherits = FALSE))
  })
  in_case("exemple note : une page et texte trop long refusé avant création", function() {
    e <- new_student_env()
    source_quiet("examples/mini_note_pdf.R", e)
    pdf_bytes <- readBin("results/mini_note.pdf", "raw", n = file.info("results/mini_note.pdf")$size)
    pdf_text <- paste(rawToChar(pdf_bytes, multiple = TRUE), collapse = "")
    stopifnot(identical(rawToChar(pdf_bytes[1:5]), "%PDF-"))
    pages <- gregexpr("/Type /Page\\b", pdf_text, perl = TRUE, useBytes = TRUE)[[1]]
    stopifnot(pages[1] > 0, length(pages) == 1L)
    expect_error_matching(e$ecrire_note_pdf(rep("Une phrase de trop.", 41), "results/note_trop_longue.pdf"), "Note trop longue")
    stopifnot(!file.exists("results/note_trop_longue.pdf"))
    expect_error_matching(e$ecrire_note_pdf(c("Une phrase.", NA), "results/note_invalide.pdf"), "sans NA")
    stopifnot(!file.exists("results/note_invalide.pdf"))
  })
  message("Parcours étudiant : ", count, " cas isolés réussis ; aucun résultat partagé modifié.")
  invisible(count)
}
run_learner_checks()
