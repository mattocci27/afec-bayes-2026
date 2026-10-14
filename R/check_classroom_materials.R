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
  fills <- list(`ex1a-task1`=c("8","20","40","100"), `ex1a-task2`=c("8","2","8","2"),
                `ex1a-task3`="0.5", `ex1b-task1`=c("0.05","0.95"), `ex1b-task2`="0.5",
                `allo-task2`="2/3", `allo-task3`=c("x_new","mu","draws$sigma"),
                `ndd-task`=c("-1","1"), `newtree`=c("mu","sigma"),
                `vslope-task`=c("0","-1","1"))
  wrap <- function(real) {
    force(real)
    function(..., use_precomputed) {
      if (missing(use_precomputed) || !isTRUE(use_precomputed)) stop("Core attempted live inference")
      real(..., use_precomputed=TRUE)
    }
  }
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
      if (!grepl("eval[[:space:]]*=[[:space:]]*FALSE",header) || label %in% names(fills)) {
        for (value in fills[[label]]) code <- sub("___",value,code,fixed=TRUE)
        stopifnot(!grepl("___",code,fixed=TRUE))
        invisible(eval(parse(text=code),env)); count <- count+1L
        if (label == "setup") env$fit_or_load <- wrap(get("fit_or_load",globalenv()))
      }
      i <- j+1L
    }
    if (day == "day1") stopifnot(mean(env$draws$p)>.4,mean(env$draws$p)<.45,
      diff(quantile(env$y_new,c(.05,.95)))>diff(quantile(env$y_plugin,c(.05,.95))))
    if (day == "day2") stopifnot(mean(env$p_low)>mean(env$p_high),
      diff(quantile(exp(env$y_new),c(.05,.95)))>diff(quantile(exp(env$mu),c(.05,.95))))
    if (day == "day3") stopifnot(mean(env$sd3$`gamma[2,2]`>0)>.95,length(env$p_new)==4000L)
    cat(day,":",count,"runnable/filled tasks and safe R chunks passed with classroom guards\n")
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
