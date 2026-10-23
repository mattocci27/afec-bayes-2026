# Validate the delivered Project in a fresh, relocated copy; no extra packages.
# Run after make day3-2: Rscript --vanilla scripts/check_day3_2.R
archive <- normalizePath("dist/afec-day3-2-materials.zip", mustWork = TRUE)
validation_dir <- tempfile("afec computing check ")
dir.create(validation_dir)
unzip(archive, exdir = validation_dir)
project <- file.path(validation_dir, "AFEC-R-basics")
original_dir <- getwd()
setwd(project)
png(file.path(validation_dir, "exercise-plot.png"), width = 840, height = 480)
script_time <- system.time(source("R/inspect_seedlings.R", echo = TRUE))
dev.off()
stopifnot(
  file.exists("AFEC-R-basics.Rproj"),
  identical(class(seedlings), "data.frame"),
  identical(dim(seedlings), c(8L, 4L)),
  identical(class(seedlings$species), "character"),
  identical(class(seedlings$survived), "logical"),
  identical(class(diameter), "numeric"),
  length(diameter) == 8L,
  is.na(diameter[4]),
  is.na(seedlings$survived[5]),
  identical(as.numeric(hist(diameter, breaks = c(0, 2, 4, 6, 8), plot = FALSE)$counts),
            c(0, 3, 3, 1)),
  nrow(head(seedlings)) == 6L,
  identical(seedlings, read.csv("data/seedlings.csv"))
)
# Check the path-base misconception using a real directory change.
setwd("R")
stopifnot(!file.exists("data/seedlings.csv"))
setwd(project)
student_html <- paste(readLines("exercise.html", warn = FALSE), collapse = "\n")
stopifnot(
  !grepl("Instructor interpretation|instructor-notes.html", student_html),
  !any(grepl("coverage-assessment|instructor|\\.RData|\\.Rproj.user",
             list.files(".", recursive = TRUE, all.files = TRUE)))
)
setwd(original_dir)
cat("Relocated Project, script, classes, dimensions, missingness, plot and exclusions: PASS\n")
cat("Script elapsed seconds:", script_time[["elapsed"]], "\n")
cat("Validation artifacts:", validation_dir, "\n")
cat("R:", as.character(getRversion()), "\n")
