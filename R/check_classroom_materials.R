# Lightweight integration check: no installation, compilation or sampling.
# Rscript R/check_classroom_materials.R
suppressPackageStartupMessages(library(tidyverse))
library(posterior)
library(here)
source(here("R/classroom_materials.R"))
source(here("R/functions.R"))
source(here("R/course_data.R"))
source(here("R/course_utils.R"))
source(here("docker/check-fits.R"))
check_course_fits(here())

check_exercises <- function() {
  old <- Sys.getenv(c("AFEC_CLASSROOM", "AFEC_STAN_BIN_DIR"), unset=NA_character_)
  on.exit(for (name in names(old)) {
    if (is.na(old[[name]])) Sys.unsetenv(name)
    else do.call(Sys.setenv, setNames(list(old[[name]]), name))
  }, add=TRUE)
  bin <- tempfile("afec-material-check-"); dir.create(bin)
  on.exit(unlink(bin, recursive=TRUE), add=TRUE)
  files <- list.files(here("stan"), "\\.stan$", full.names=TRUE)
  manifest <- setNames(lapply(files, function(f) list(md5=unname(tools::md5sum(f)))), basename(files))
  saveRDS(manifest, file.path(bin,"manifest.rds"))
  Sys.setenv(AFEC_CLASSROOM="TRUE", AFEC_STAN_BIN_DIR=bin)
  # This fixture exercises source/data guards, not actual model executables.
  wrap <- function(real) {
    force(real)
    function(..., use_precomputed) {
      if (missing(use_precomputed) || !isTRUE(use_precomputed)) stop("Core attempted live inference")
      real(..., use_precomputed=TRUE)
    }
  }
  original_fit_or_load <- fit_or_load
  on.exit(assign("fit_or_load", original_fit_or_load, envir=globalenv()), add=TRUE)
  for (day in paste0("day",1:3)) {
    lines <- readLines(here(day,"exercise-student.qmd"))
    stopifnot(identical(lines, student_source(readLines(here(day,"exercise.qmd")))))
    stopifnot(!any(grepl('when-meta="solutions"|ex1b-sol|allo-sol|tenx-sol|## Solution',lines)))
    env <- new.env(parent=globalenv()); count <- 0L; i <- 1L
    while (i <= length(lines)) {
      if (!grepl("^```\\{r",lines[i])) {i <- i+1L; next}
      header <- lines[i]; label <- sub("^```\\{r[[:space:]]*([^,}]*).*", "\\1",header)
      j <- i+1L
      while (j <= length(lines) && !grepl("^```[[:space:]]*$",lines[j])) j <- j+1L
      stopifnot(j <= length(lines)); code <- paste(lines[(i+1L):(j-1L)],collapse="\n")
      if (!grepl("eval[[:space:]]*=[[:space:]]*FALSE",header)) {
        stopifnot(!grepl("___",code,fixed=TRUE))
        invisible(eval(parse(text=code),env)); count <- count+1L
        if (label == "setup") assign("fit_or_load",wrap(get("fit_or_load",globalenv())),envir=globalenv())
      }
      i <- j+1L
    }
    if (day == "day1") {
      stopifnot(!any(grepl("source\\(|course_fit\\(|plot_update\\(", lines)))
      exact <- dbeta(env$p, 3, 4); exact <- exact / sum(exact)
      stopifnot(max(abs(env$posterior - exact)) < 1e-12)
      # Run two possible participant-chosen surveys using the supplied chunk.
      first <- match("```{r core-data-comparison, fig.height=3.4}", lines)
      last <- first + match("```", lines[(first + 1L):length(lines)])
      starter <- lines[(first + 1L):(last - 1L)]
      variances <- numeric(2)
      for (k in 1:2) {
        N <- c(10, 50)[k]; y <- 0.4 * N
        code <- starter
        code[code == "y <- 2"] <- paste("y <-", y)
        code[code == "N <- 5"] <- paste("N <-", N)
        chosen <- new.env(parent=globalenv())
        eval(parse(text=code), chosen)
        exact <- dbeta(chosen$p, y + 1, N - y + 1)
        exact <- exact / sum(exact)
        stopifnot(max(abs(chosen$posterior - exact)) < 1e-12,
                  chosen$y/chosen$N == 0.4, identical(chosen$p, env$p))
        variances[k] <- sum(chosen$posterior *
          (chosen$p - sum(chosen$p * chosen$posterior))^2)
      }
      stopifnot(variances[2] < variances[1])
    }
    if (day == "day2") {
      low <- env$probabilities$p[env$probabilities$density == -1]
      high <- env$probabilities$p[env$probabilities$density == 1]
      stopifnot(mean(low)>mean(high),all(env$predictions$seedlings==20),
        identical(dim(env$replicates),c(4000L,60L)),
        all(env$replicates>=0),all(sweep(env$replicates,2,env$ndd$n,">")==FALSE))
    }
    if (day == "day3") stopifnot(nrow(env$comparison)==24L,length(env$p_new)==4000L,
      all(env$comparison$lower<=env$comparison$mean),
      all(env$comparison$mean<=env$comparison$upper))
    core <- grep("^# Core exercise:",lines,value=TRUE)
    stopifnot(length(core)==1L)
    if (day != "day1") {
      diagnostics <- course_diagnostics(env$fit)
      stopifnot(all(is.finite(as.matrix(diagnostics))),diagnostics$max_rhat<=1.01,
                diagnostics$min_bulk_ess>400,diagnostics$divergent==0)
    }
    cat(day,":",count,"safe chunks and one completed core exercise passed with classroom guards\n")
  }
  changed <- try(fit_or_load("day1_seedling","stan/binomial.stan",
                            list(N=100,y=40,a=1,b=1),use_precomputed=TRUE),silent=TRUE)
  stopifnot(inherits(changed,"try-error"),grepl("does not match",changed))
  manifest$binomial.stan$md5 <- "stale-source"; saveRDS(manifest,file.path(bin,"manifest.rds"))
  stale <- try(fit_or_load("day1_seedling","stan/binomial.stan",
                          list(N=5,y=2,a=1,b=1),use_precomputed=TRUE),silent=TRUE)
  stopifnot(inherits(stale,"try-error"),grepl("No matching precompiled",stale))
  cat("Changed-input and stale-source rejection retained.\n")
}
check_exercises()
for (file in list.files(here("fits"),"\\.rds$",full.names=TRUE)) {
  fit <- readRDS(file); s <- summarise_draws(fit$draws,rhat,ess_bulk,ess_tail)
  row <- tibble(fit_name=basename(file),max_rhat=max(s$rhat,na.rm=TRUE),
                min_bulk=min(s$ess_bulk,na.rm=TRUE),min_tail=min(s$ess_tail,na.rm=TRUE),
                divergences=sum(fit$diagnostics$num_divergent),
                treedepth=sum(fit$diagnostics$num_max_treedepth),min_ebfmi=min(fit$diagnostics$ebfmi))
  print(row,width=Inf)
  if (!grepl("_bad\\.rds$",file)) stopifnot(row$max_rhat<=1.01,row$min_bulk>400,
    row$min_tail>400,row$divergences==0,row$treedepth==0,row$min_ebfmi>.3)
}
cat("Seven fits checked; the deliberately bad fit is exempt from healthy-fit thresholds.\n")
