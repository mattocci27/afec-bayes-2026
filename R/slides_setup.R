# Shared setup for day1/slides.qmd, day2/slides.qmd, day3/slides.qmd.
# A lean version of setup.Rmd (which main.qmd still uses): same chunk options
# and ggplot theme, but no dependency on the targets store, so the slides
# render from the stored results in fits/ without running Stan.

library(knitr)
library(tidyverse)
library(patchwork)
library(posterior)
library(kableExtra)
library(here)

source(here("R/functions.R"))
source(here("R/course_data.R"))
source(here("R/course_utils.R"))
source(here("R/course_visuals.R"))

knitr::opts_chunk$set(
  echo       = FALSE,
  warning    = FALSE,
  message    = FALSE,
  comment    = " ",
  dev.args   = list(bg = "transparent"),
  fig.align  = "center",
  fig.show   = "hold",
  fig.retina = 3
)
options(width = 1000)

# Same colours as the equations in the slides (RColorBrewer "Dark2")
col_like  <- "#1b9e77" # likelihood
col_post  <- "#d95f02" # posterior
col_prior <- "#7570b3" # prior

largefontthm <- theme_bw() + theme(
  axis.title    = element_text(size = 28),
  axis.text     = element_text(size = 24),
  strip.text    = element_text(size = 20),
  plot.title    = element_text(size = 32),
  plot.subtitle = element_text(size = 18),
  plot.caption  = element_text(size = 14),
  legend.text   = element_text(size = 20),
  legend.title  = element_text(size = 20)
)
theme_set(largefontthm)

# Stored model results (see R/precompute_fits.R)
read_fit <- function(name) readRDS(here("fits", paste0(name, ".rds")))

# Print a Stan file as a code block (use in a chunk with results = "asis")
show_stan <- function(file, compact = FALSE) {
  lines <- readLines(here(file))
  if (compact) {
    lines <- sub("[[:space:]]*//.*$", "", lines)
    lines <- lines[nzchar(trimws(lines))]
  }
  cat("```stan\n", paste(lines, collapse = "\n"), "\n```\n", sep = "")
}
