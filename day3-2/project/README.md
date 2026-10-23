# AFEC R foundations: participant project

1. Extract the complete ZIP before opening files. Keep the folder structure.
2. Open `AFEC-R-foundations.Rproj` in RStudio. In a browser RStudio session,
   upload/extract the ZIP, then open the Project from the Files pane.
3. Open `exercise.html` for the guided instructions (in the ZIP), or use the
   course handout. Open `R/inspect_seedlings.R` in RStudio's Source editor.
4. Run its numbered sections from the top using Run or Ctrl+Enter (Cmd+Enter
   on macOS). The exercise uses base R; no package installation is needed.

The Project folder is the initial working directory. The script deliberately
uses `data/seedlings.csv`, relative to that directory, even though the script
itself is in `R/`. Do not set the working directory to `R/` or `data/`.
Opening or saving a script does not execute it. The Environment shows live
objects; reopening the Project requires rerunning the script.

## Data dictionary

These are eight fictional records written for this lesson, not observations
from a forest and not data from the statistical sessions. Each row is one
tagged seedling followed over a single observation interval.

| Column | Meaning | Expected R class after read.csv() |
|---|---|---|
| seedling_id | Unique seedling identifier | character |
| species | Fictional species label; two species | character |
| diameter_mm | Initial seedling stem diameter, in millimetres | numeric |
| survived | Alive at the later census: TRUE; dead: FALSE | logical |

`NA` marks an unrecorded value: s04 lacks a diameter measurement; s05 lacks a
survival observation. Unknown survival is not a recorded death. The CSV has
8 data rows plus a header. Keep the supplied input unchanged.

The histogram uses seven measured diameters; its vertical axis counts seedlings.
The script prints to the Console and draws to Plots; it does not overwrite data.

## Optional report

`report.qmd` contains Markdown prose and runnable R code; `report.html` is its
prepared output. Read the HTML without R or Quarto. If RStudio already has
Quarto and knitr, open `report.qmd` and click Render. The document imports its
own data from its own directory; it does not depend on Console objects.

For this project, keep R's workspace restore/save disabled (already set in the
.Rproj). Save scripts, inputs, documentation and any deliberately exported
outputs together. A Project does not by itself record package versions or make
backups. No toolchain, CmdStan, Docker or internet is needed for the core script.
