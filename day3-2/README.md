# Day 3-2: Introduction to R and Research Computing

A 60-minute consolidation session after the separate 30-minute lecture.
Materials are in English, with one 15-minute guided practical and no statistical
inference lesson. Start with the instructor notes for timing and the evidence
from previous instruction; the planning assessment distinguishes coverage from
inferred learning gaps.

- `slides.qmd` / `slides.html`: 16 slides, including an optional Quarto example.
- `exercise.qmd` / `exercise.html`: instructor source and rendered answers.
- `exercise-student.qmd` / `.html`: generated solution-free participant handout.
- `instructor-notes.qmd` / `.html`: timing, demonstrations, misconceptions and
  mapping to Ninya Quibod's `nina/` materials.
- `project/`: standalone participant Project, small fictional dataset, generated
  script and prepared Quarto report. The practical needs only base R.

Build this extra session without rebuilding or refitting the statistical course:

```sh
make day3-2
Rscript --vanilla scripts/check_day3_2.R
```

The builder reuses the existing solution-removal code, generates the R script
from the four core exercise chunks, renders the documents and packages
`dist/afec-day3-2-materials.zip`. Distribute that ZIP; extract the whole folder
and open `AFEC-R-foundations.Rproj`. Slides, exercise and report HTML embed their
resources. Instructor notes, answers and coverage assessment are excluded.
The exercise QMD's authoring setup uses the repository's `project/` subfolder;
participants use the generated script and portable HTML, not that authoring QMD.

Edit `exercise.qmd`, not generated participant sources or the script. Slides
reuse the existing AFEC theme, logo and palette; `session.css` only adjusts
code/table readability. The root course builders, website and all-days ZIP do
not automatically include this extra session. `make day3-2` is its separate
build entry point. No deployment or change to Day 1–3 fitting is involved.
