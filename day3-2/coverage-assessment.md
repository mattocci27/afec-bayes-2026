# Day 3-2: prior instruction and likely learning gaps

Instructor planning assessment, prepared before authoring the new materials.
2026-10-23. This is evidence about teaching materials, not measured student mastery.

## Sources actually inspected

- All 30 pages of `nina/20261020_Getting started with R.pdf`, including pane
  screenshots and data-cleaning diagram; corresponding PPTX slide text and notes.
- Complete `nina/20261020_Getting started with R_script.R`.
- Current Day 1–3 slides and exercise conventions, README, AGENTS.md,
  classroom scope and instructor pacing guidance.
- The PPTX has 30 slides; its notes add source links/page numbers, no additional
  Project lesson. DIVER.csv and the height/sex practice data are not in `nina/`.
  Their actual values and whether students completed the tasks are unknown.

## Coverage and instructional decisions

A = documented exposure, plausible familiarity; B = documented exposure with
likely conceptual ambiguity; C = not found in these materials, essential here.
These are planning hypotheses. Reassign emphasis after the short oral checks.

| Category | Documented coverage and depth | Inferred gap / decision for Day 3-2 |
|---|---|---|
| A | pp. 8–13: arithmetic, case sensitivity, assignment with Harry/Potter; script: comments, c(), sum(), mean(), help | Brief reminder through an ecological import statement; no arithmetic or naming-rule drills. Exposure is substantial; fluency remains unmeasured. |
| A | pp. 25–26: package installation, hist(); script: extensive installations, histogram, boxplot and ggplot on diver respiration/experience | Supply one base-R histogram; do not reteach plot syntax or install anything. Familiarity with seeing a plot is plausible, proficiency is unknown. |
| B | pp. 5, 7, 14–15: screenshots, Console vs Source, reopen exercise; advice says never write in Console | Explain saved instructions vs execution vs live objects. Console checks are legitimate; history is not a reproducible script. Saving a script does not run it or save its objects. |
| B | p. 19: getwd()/setwd(); script uses two machine-specific Windows paths; advice says all files must be in the same location | Explain folders, extensions, path base and subfolders. A file can be elsewhere in the same project; a script's folder and Files-pane location do not automatically set the Console working directory. |
| B | pp. 16–18 list numeric/integer/character/logical/complex and vector/list/matrix/data frame/factor with Harry Potter examples | Too many categories in few slides may obscure type vs structure. Link a data frame to its equal-length column vectors; use numeric/character/logical and one small coercion example. No list exercise, matrix or factor lesson. |
| B | p. 20 and script import DIVER.csv into diver using read.table(); p. 24 converts experience; script adds respiration_log | Distinguish CSV on disk, object name in memory, quoted path and a column. Assignment changes memory; a separate write is needed for a file. Reading code is the task, not syntax production. |
| B | p. 21 mentions NA, missing values and duplicates without a worked missing-data example | Show measured diameter missing vs zero, unknown survival vs FALSE; inspect is.na(). No imputation or statistical missing-data lesson. |
| B | p. 22 and script list names(), summary(), levels(), dim(), str(), head(), tail(), plus column extraction | Read actual outputs, especially rows vs columns and each column's type. Use class(), str(), head() together. Do not repeat the full catalogue. |
| C | No explicit RStudio Project workflow, worked absolute/relative comparison, file-extension map or restart-and-rerun workflow found | Introduce a prepared .Rproj with separate data/ and R/ folders; opening it establishes the initial working directory. Show how a relative path survives relocation of the whole folder. |
| C | No class() example, Markdown or Quarto explanation found | Add class() to compare the table and a column. Include a required .qmd -> .html walkthrough: read text and R code, click Render, then open the report. |

## Accuracy points to clarify without criticizing previous instruction

- head()/tail() default to six rows, not five (p. 22 and script).
- `$column` selects a column, not a row (the summary annotation says row).
- levels() concerns factor levels, not the unique values of every vector.
- A bare `30` is normally numeric/double in R; `30L` is integer. Mention in
  instructor notes only if asked; whole numbers and stored integer type differ.
- CSV is convenient here, not R's only readable format. read_excel() belongs to
  readxl, not dplyr; Excel import is outside this session.
- An atomic vector has one underlying type. A data frame can combine column
  types because its columns are separate vectors; printed appearance is insufficient.
- RStudio Projects organize context, not a complete backup or dependency manager.

## Planned session and limits

6 min files, 19 min paths/Projects/objects, 20 min types/structures/
inspection/missing values, 15 min one integrated practical (including recap and
questions and a required three-minute Quarto report walkthrough). Quarto
is included within the 60-minute slot. This follows the separate 30-minute lecture;
there is no statistical-model or inference lesson in Day 3-2.

Use eight explicitly fictional seedling records with species labels, initial
stem diameter in mm and later survival status. The unit is one tagged seedling
followed over one interval, not a species or quadrat. One diameter and one
survival observation are missing. Provide the project, all code and an expected
output route. The R script uses base R; the required report walkthrough also
needs Quarto and knitr ready in the class environment. No loops, custom functions, complex indexing, installation,
matrices, factor internals, list manipulation or general programming tutorial.
