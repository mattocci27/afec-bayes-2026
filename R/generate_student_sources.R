# Run from the project root; no packages or fitted results are needed.
# Rscript R/generate_student_sources.R [day1 day2 day3]
source("R/classroom_materials.R")
days <- commandArgs(trailingOnly = TRUE)
if (!length(days)) days <- paste0("day", 1:3)
generate_student_sources(days)
