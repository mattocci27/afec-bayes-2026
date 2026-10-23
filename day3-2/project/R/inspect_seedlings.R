# AFEC Day 3-2: run in the prepared RStudio Project.
# Each row follows one fictional seedling over one interval.
# diameter_mm: initial stem diameter (mm); survived: TRUE/FALSE/NA.
# Read the data dictionary in README.md. No packages needed.
# Run sections from the top; saving this script does not run it.
# Generated from day3-2/exercise.qmd; edit that source to revise.

# 1. location
file.exists("data/seedlings.csv")

# 2. import-data
seedlings <- read.csv("data/seedlings.csv")
class(seedlings)
str(seedlings)
head(seedlings)
dim(seedlings)

# 3. inspect-column
diameter <- seedlings$diameter_mm
class(diameter)
length(diameter)
is.na(diameter)
class(seedlings$species)
class(seedlings$survived)

# 4. diameter-plot
hist(
  seedlings$diameter_mm,
  breaks = c(0, 2, 4, 6, 8),
  main = "Initial seedling stem diameter",
  xlab = "Stem diameter (mm)",
  ylab = "Number of seedlings",
  col = "#1b9e77",
  border = "white"
)
