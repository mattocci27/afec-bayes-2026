# Instructor only: Rscript R/build_classroom_materials.R
# Uses existing fits; never compiles or samples Stan.
suppressPackageStartupMessages(library(tidyverse))
library(here)
source(here("R/classroom_materials.R"))
package_only <- "--package-only" %in% commandArgs(trailingOnly = TRUE)
build_classroom_materials(render = !package_only)
