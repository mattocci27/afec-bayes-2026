# AGENTS.md

## Course and communication
- Build on the ecological examples for ecology researchers: three 90-minute Bayesian statistics sessions.
- Consult the instructor in Japanese; keep existing English teaching materials in English unless translation is requested.
- Prioritize estimation, interpretation, uncertainty, predictions and model checking over model coverage.
- Follow the agreed scope in `classroom/restructure-proposal.md` and timing in `classroom/instructor.md`; consult `README.md` for current workflows. State unresolved assumptions explicitly.
- Keep each session within 90 minutes, including explanation, demonstrations, one core exercise, questions and buffer. Label optional extensions and what to omit when time is short.
- Give exercises a clear purpose, runnable supplied code, expected observations and interpretation; separate instructor solutions from participant instructions. Explain shared model structure when examples differ.

## Source map and editing
- `day1/`, `day2/`, `day3/` contain the current `slides.qmd`, `exercise.qmd` (instructor source) and `results.qmd` (offline results).
- Edit `exercise.qmd`, not generated `exercise-student.qmd`; generation removes solutions. Day 1 detailed explanations and optional fitting demonstrations live in `day1/instructor-notes.qmd`.
- `main.qmd` and root `exercise.qmd` are preserved 2025 source materials; `archive/teaching-before-cndd/` is instructor reference, excluded from the participant ZIP.
- Shared data, helpers and figures live in `R/`; models in `stan/`; stored draws and diagnostics in `fits/`; course styles in `assets/course.scss` and `assets/course.css`.
- Preserve existing user changes, themes, layouts, references and unrelated content. Keep edits focused; follow the [tidyverse R style guide](https://style.tidyverse.org/).
- Avoid machine-specific absolute paths. Set simulation seeds and verify stored results match the code and data; changing inputs requires new inference.
- Don't use user defined functions in exercises without showing the original codes.

## Statistical integrity
- Keep ecological questions, equations, data generation, estimation and explanations consistent, including indexing, transformations, SD/variance notation, links and coefficient interpretations.
- Distinguish posterior distributions, posterior means, MAP and MLE; explain partial pooling in terms of assumptions and data. Relate priors to variable scales and use prior predictive checks where appropriate.
- When comparing Stan and brms, verify model formulations, priors and transformations. When varying priors or sample sizes, state what stays fixed and what to compare.
- Assess convergence, divergences, posterior predictive checks and ecological context together; no single diagnostic establishes adequacy. Label intentionally problematic teaching fits.
- Verify uncertain technical claims with official documentation or original sources; disclose unresolved uncertainty and never invent results or citations.

## Classroom and validation environments
- **Never require participant installation of CmdStan, a C++ toolchain or Docker.** Prefer a preconfigured browser R environment; keep local installation optional and separate.
- Supply precomputed posterior draws, diagnostics and predictions, plus the figure-reading/offline route. Clearly label new-inference exercises versus analysis of prepared results.
- Distinguish instructor validation from classroom readiness. Before class, test a fresh participant copy/account, required plotting and any offered compilation/sampling; account for connectivity, resources and measured runtime.
- Inspect the actual environment and dependencies before installing packages or creating containers. Use a working local environment or existing project container; follow the documented Docker workflow where applicable (`docker/README.md`).
- Local checks do not establish browser login, deployment or simultaneous classroom capacity. Record relevant versions and commands; report remaining classroom checks separately.

## Build and execution (repository root)
- **Use `_targets.R` only for legacy MH/HMC GIF regeneration in `images/`.** Do not use `targets` for course model fitting, rendering or exercises; inspect dependencies before running the legacy pipeline.
- **`Rscript R/precompute_fits.R` refits every course model into `fits/`.** Run only when model/data/sampling changes require it, never for documentation edits or routine rebuilds.
- `make day1` / `make day2` / `make day3`: regenerate that day's participant source as needed and render slides, instructor/participant exercises and results (plus Day 1 notes), using existing fits.
- `make slides`: render slides only. `make materials` (or `Rscript R/build_classroom_materials.R`): build materials and refresh `dist/afec-classroom-materials.zip` using existing fits; daily builds do not refresh the ZIP.
- `Rscript R/build_classroom_materials.R --package-only`: package after a successful render; rejects missing/stale HTML. Direct `quarto render dayN/exercise.qmd` does not regenerate the participant source.
- Distribute the solution-free participant ZIP; cloning alone omits gitignored fits. Check `classroom/PACKAGES.md` for participant requirements and validate offline resources and instructor-content exclusions.

## Validation and completion
- Text-only changes: check factual accuracy, equations, references and presentation effects; do not run unnecessary model calculations.
- Code changes: execute affected sections and inspect outputs/diagnostics. `Rscript R/check_classroom_materials.R` checks filled participant tasks and stored fits without new inference (see README for environment-specific invocation).
- Layout changes: render affected materials and visually inspect text density, overflow, figures, equations and code readability.
- Report changes, teaching value, validation results and remaining decisions. If execution is unavailable, state exactly what was checked, what remains unverified and why.
