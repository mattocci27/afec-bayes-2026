# AGENTS.md

## Project Goal

Restructure the existing Bayesian statistics materials for ecology researchers into three 90-minute sessions combining lectures and exercises.

Build on the existing ecological examples. Help participants understand model assumptions, interpret estimates, and evaluate their models.

## Materials and Assumptions

- `main.qmd`: lecture slides using Quarto revealjs.
- `exercise.qmd`: practical exercises using Quarto HTML.
- Inspect relevant R and Stan code, data, images, and configuration files as needed.
- Participants' prior knowledge, the teaching language, whether participants must write Stan code independently, and homework requirements remain undecided. State assumptions explicitly in proposed designs.
- Communicate with the instructor in Japanese. Keep existing English teaching materials in English unless translation is requested.

## Course Design

- Define observable learning outcomes for each session.
- Include lectures, demonstrations, participant exercises, explanations, questions, and buffer time within each 90-minute session.
- Distinguish core content, optional extensions, preparation, and homework. Identify what to shorten or omit if time runs out.
- Introduce concepts through ecological questions, concrete examples or figures, mathematical formulations, and code.
- When lectures and exercises use different examples, explain the shared model structure and the differences.
- Prioritize completing a cycle of estimation, interpretation, and model checking over covering many models.
- Account for computation time and setup problems. Provide fitted results when useful.

## Exercise Design

- Specify each exercise's purpose, estimated duration, starter code, instructions, and expected observations.
- Go beyond running code. Include predictions, changes to conditions, comparisons, and interpretation in words.
- Separate core tasks from optional extensions to accommodate different learning speeds.
- Provide solutions that explain both the code and the interpretation, including common misunderstandings.
- When changing priors or sample sizes, specify what stays fixed and what participants should compare.
- Clearly distinguish participant instructions from instructor solutions and notes.

## Statistical Accuracy

- Check consistency among ecological questions, equations, data-generating code, estimation code, and explanations.
- Use consistent indexing, variable transformations, standard deviation and variance notation, link functions, and coefficient interpretations.
- Distinguish posterior distributions, posterior means, MAP estimates, and MLEs.
- Explain how the effects of partial pooling depend on model assumptions and data.
- Relate priors to variable scales and use prior predictive checks where appropriate.
- Assess inference using convergence diagnostics, divergent transitions, posterior predictive checks, and relevant contextual evidence. Do not treat a single diagnostic as sufficient.
- Clearly label problematic fits when they are included for teaching diagnostics.
- Verify uncertain technical details using official documentation or original sources. State unresolved uncertainty and never invent citations or results.

## Editing and Execution

- For design consultations, provide proposals and reasons. When editing is requested, complete the requested changes and relevant validation.
- Respect existing themes, layouts, code chunks, and references. Keep changes focused on the task.
- Follow the repository's configuration and README. Verify the execution environment and dependencies instead of assuming they exist.
- Avoid introducing machine-specific absolute paths. Consider configuration or environment variables for existing fixed paths.
- Set random seeds for simulations. When reusing fitted results, verify that they match the corresponding code and data.
- When comparing Stan and brms, check differences in model formulations, priors, and variable transformations.

## Execution Environment

- Docker is optional. Use a working local environment or an existing project container.
- Check the environment before installing dependencies or introducing a new container.
- If Docker is already the project's documented execution environment, use it for code execution and rendering.
- Record relevant software versions and execution commands so validation can be reproduced.
- Treat the instructor's validation environment and the participants' classroom setup as separate decisions.

## Validation and Reporting

- For text-only changes, check equations, references, and effects on presentation.
- For code changes, run the affected sections and inspect outputs and diagnostics.
- For slide or page layout changes, render the materials and check text density, overflow, and the readability of figures, equations, and code.
- If execution is unavailable, report what was checked, what remains unverified, and why.
- On completion, briefly summarize the changes, their teaching value, validation results, and remaining decisions.


## Execution Environment

- Do not require participants to install CmdStan, a C++ toolchain, or Docker on their own computers.
- Prefer a preconfigured browser-based R environment for classroom exercises.
- Prepare and validate the environment before the course. Test a fresh participant copy or account, including compilation, sampling, and plotting.
- Use Docker on the instructor or server side when helpful for reproducibility.
- Provide precomputed posterior draws, diagnostic results, and predictions as a fallback for computational exercises.
- Clearly distinguish exercises that run new inference from exercises that analyze precomputed results.
- Account for classroom connectivity, available computing resources, and measured execution time when designing exercises.
- Keep local installation instructions optional and separate from the core classroom workflow.
