# Generate participant sources and an offline package. Never run inference.
student_source <- function(lines) {
  output <- character(); depth <- 0L; fenced <- FALSE
  for (line in lines) {
    if (grepl("^```", line)) fenced <- !fenced
    if (!fenced && grepl('^::: \\{[.]content-visible when-meta="solutions"\\}$', line)) {
      if (depth != 0L) stop("Nested solution wrapper")
      depth <- 1L
      next
    }
    if (depth > 0L) {
      if (!fenced && grepl("^:{3,}[^:]", line)) depth <- depth + 1L
      if (!fenced && grepl("^:{3,}[[:space:]]*$", line)) depth <- depth - 1L
      next
    }
    output <- c(output, line)
  }
  if (depth != 0L || fenced) stop("Unclosed solution Div or code fence")
  output[output == "solutions: true"] <- "solutions: false"
  if (any(grepl('when-meta="solutions"|^## (Solution|Notes for the discussion)', output)))
    stop("Solution content remains in participant source")
  output
}

# Source generation also runs independently of saved fits and rendering.
generate_student_sources <- function(days = paste0("day", 1:3)) {
  if (!length(days) || any(!days %in% paste0("day", 1:3)))
    stop("Choose day1, day2 or day3")
  for (day in days) {
    participant <- file.path(day, "exercise-student.qmd")
    lines <- student_source(readLines(file.path(day, "exercise.qmd")))
    if (!file.exists(participant) || !identical(readLines(participant), lines))
      writeLines(lines, participant)
  }
  invisible(TRUE)
}

build_classroom_materials <- function(root = here::here(), render = TRUE,
                                      render_slides = TRUE, package = TRUE) {
  root <- normalizePath(root, mustWork = TRUE)
  old_wd <- getwd(); on.exit(setwd(old_wd), add = TRUE); setwd(root)
  old_mode <- Sys.getenv("AFEC_USE_PRECOMPUTED", unset = NA_character_)
  on.exit(if (is.na(old_mode)) Sys.unsetenv("AFEC_USE_PRECOMPUTED")
          else Sys.setenv(AFEC_USE_PRECOMPUTED = old_mode), add = TRUE)
  Sys.setenv(AFEC_USE_PRECOMPUTED = "TRUE")
  generate_student_sources()
  env <- new.env(parent = globalenv())
  for (file in c("R/functions.R", "R/course_data.R", "docker/check-fits.R"))
    sys.source(file, env)
  data <- env$check_course_fits(root)
  dir.create("data", showWarnings = FALSE)
  for (name in names(data))
    readr::write_csv(data[[name]], file.path("data", paste0(name, ".csv")))
  saveRDS(data, "data/course-data.rds")
  if (render) {
    if (!nzchar(Sys.which("quarto"))) stop("Quarto is required to render handouts")
    for (day in paste0("day", 1:3)) {
      docs <- c("exercise.qmd", "exercise-student.qmd", "results.qmd")
      if (day == "day1") docs <- c(docs, "instructor-notes.qmd")
      if (render_slides) docs <- c("slides.qmd", docs)
      for (doc in docs) {
        input <- file.path(day, doc)
        message("Rendering ", input, " (stored results only)")
        if (system2("quarto", c("render", shQuote(input))) != 0L) stop("Render failed: ", input)
      }
    }
    if (system2("quarto", c("render", "classroom/readiness.qmd")) != 0L)
      stop("Readiness render failed")
    if (system2("quarto", c("render", "classroom/instructor.md")) != 0L)
      stop("Instructor schedule render failed")
  }
  if (package) {
    # Resume after a completed render without launching another render. Reject
    # missing/stale HTML, including a changed generated participant source.
    inputs <- c(unlist(lapply(paste0("day", 1:3), function(day)
      file.path(day, c("slides.qmd", "exercise-student.qmd", "results.qmd")))),
      "classroom/readiness.qmd")
    outputs <- sub("\\.qmd$", ".html", inputs)
    if (!all(file.exists(outputs)) || any(file.info(outputs)$mtime < file.info(inputs)$mtime))
      stop("Render current handouts before packaging")
    shared <- c("R/functions.R", "R/course_data.R", "R/course_utils.R", "R/course_visuals.R")
    newest_shared <- max(file.info(shared)$mtime)
    course_html <- outputs[grepl("^day[123]/", outputs)]
    if (any(file.info(course_html)$mtime < newest_shared))
      stop("Render course documents after changing shared R code before packaging")
    # Quarto emits a few whitespace-only lines; keep generated Git diffs clean.
    html <- c(outputs, file.path(paste0("day", 1:3), "exercise.html"))
    for (file in html) {
      lines <- readLines(file, warn = FALSE)
      cleaned <- sub("[[:blank:]]+$", "", lines)
      if (!identical(lines, cleaned)) writeLines(cleaned, file)
    }
    stage <- tempfile("afec-classroom-pack-"); dir.create(stage)
    on.exit(unlink(stage, recursive = TRUE), add = TRUE)
    file.copy(".here", stage)
    file.copy("docker/START-HERE.md", file.path(stage, "START-HERE.md"))
    writeLines(c("Version: 1.0", "RestoreWorkspace: No", "SaveWorkspace: No",
                 "AlwaysSaveHistory: No", "Encoding: UTF-8"), file.path(stage, "afec-bayes-2026.Rproj"))
    writeLines('Sys.setenv(AFEC_USE_PRECOMPUTED = "TRUE")', file.path(stage, ".Rprofile"))
    for (dir in c("R", "stan", "fits", "data", "classroom")) dir.create(file.path(stage, dir))
    for (file in c("course_utils.R", "course_data.R", "course_visuals.R", "functions.R"))
      file.copy(file.path("R", file), file.path(stage, "R", file))
    file.copy(list.files("stan", "\\.stan$", full.names = TRUE), file.path(stage, "stan"))
    file.copy(list.files("fits", "\\.(rds|txt)$", full.names = TRUE), file.path(stage, "fits"))
    file.copy(list.files("data", full.names = TRUE), file.path(stage, "data"))
    file.copy(c("classroom/readiness.qmd", "classroom/readiness.html", "classroom/PACKAGES.md"), file.path(stage, "classroom"))
    for (dir in c("images", "assets")) file.copy(dir, stage, recursive = TRUE)
    for (day in paste0("day", 1:3)) {
      dir.create(file.path(stage, day))
      files <- file.path(day, c("slides.html", "exercise-student.qmd", "exercise-student.html",
                                "results.qmd", "results.html"))
      stopifnot(all(file.exists(files)))
      file.copy(files, file.path(stage, day))
      for (name in c("slides_files", "exercise-student_files", "results_files")) {
        path <- file.path(day, name)
        if (dir.exists(path)) file.copy(path, file.path(stage, day), recursive = TRUE)
      }
    }
    files <- list.files(stage, recursive = TRUE, all.files = TRUE, full.names = TRUE)
    files <- files[!dir.exists(files)]
    write.table(data.frame(file = substring(files, nchar(stage) + 2L),
                          md5 = unname(tools::md5sum(files))), file.path(stage, "materials.tsv"),
                sep = "\t", quote = FALSE, row.names = FALSE)
    dir.create("dist", showWarnings = FALSE)
    archive <- file.path(root, "dist", "afec-classroom-materials.zip")
    # Replace only this generated archive; zip must not retain obsolete entries.
    if (file.exists(archive)) unlink(archive)
    setwd(stage)
    if (utils::zip(archive, list.files(".", all.files = TRUE, no.. = TRUE), flags = "-qr") != 0L)
      stop("Classroom archive creation failed")
    setwd(root); message("Participant archive: ", archive)
  }
  invisible(TRUE)
}
