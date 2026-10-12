# AFEC 2026 classroom Docker image

One image supplies 30 independent RStudio Server containers on the Ubuntu Intel
server. Container creation, passwords, ports and resource limits belong to a
future Compose configuration; no Compose file is included here.

## Repository audit and scope

| Existing component | Classroom decision |
|---|---|
| Previous Dockerfile | Replace the custom R 4.5 base and final `USER rstudio` |
| `renv.lock` | Already R 4.6.1; retain unchanged, select 156 of its 270 packages |
| `.Rprofile` | Keep locally; exclude its host proxies, all-core settings and renv activation |
| `day1`–`day3`, shared R helpers | Include current course materials and seeded data generation |
| `stan/` | Include 14 sources; configure precompilation of 13 valid models |
| `fits/` | Include seven existing RDS files and their original environment record; do not refit during build |
| Images, theme, Font Awesome | Include static figures/GIFs and runtime CSS/JS/fonts/licenses |
| `_targets.R`, MH/HMC generation, `run.sh` | Exclude the legacy GIF/HPC pipeline and its caches |
| `main.qmd`, root `exercise.qmd`, `setup.Rmd`, `docs/hmc.qmd` | Preserve in the repository, not in participant workspaces |
| `.devcontainer/` | Legacy development configuration, not the classroom workflow |

The old exercise has CmdStan 2.36.0 paths and `parallel_chains=4`; the targets
pipeline uses multicore. Neither is suitable for unchanged classroom deployment.
`stan/mv_logistic.stan` references undefined `phi`, `plot`, `xi`, `census`, `psi`
and `tag` in generated quantities, so it is excluded from compilation. Its
statistical formulation has not been guessed or repaired. `linear_bad.stan`
remains intentionally problematic for teaching diagnostics; do not run it live
in class merely because it compiles.

## Image and workspace layout

- `/opt/afec/library`: locked R packages, root-owned and student-readable.
- `/opt/cmdstan/cmdstan-2.38.0`: shared CmdStan, retaining toolchain resources/PCH/TBB.
- `/opt/afec/models`: Linux executables and a source-MD5 manifest, not student-writable.
- `/opt/afec/template`: starter materials, seven fits, exported CSV/RDS data and slide HTML.
- `/home/rstudio/workspace/afec-bayes-2026`: the student's editable copy.
  Persist **only `/home/rstudio/workspace`**, using a separate volume per student.
- `/opt/afec/classroom.lock`, `packages.tsv`, `materials.tsv`, `build-session.txt`:
  selected versions, material hashes and build environment records.

Rocker's `/init`, RStudio service and user configuration are retained.
`00-afec-guard` requires authentication, `ROOT=FALSE` and a runtime password.
`03-afec-workspace` runs after Rocker's UID/GID setup and atomically publishes
the first starter copy. An existing student course is never recopied, replaced
or recursively chmod/chowned. Interrupted `.afec-init.*` directories are not
automatically deleted. Keep UID/GID stable across restarts. Image updates require
a new volume or an explicit migration that preserves student edits.
IDE settings outside the workspace are not persistent across container recreation.

## R packages and CmdStan

Main locked versions: tidyverse 2.0.0, ggplot2 4.0.3, posterior 1.7.0,
bayesplot 1.16.0, patchwork 1.3.2, here 1.0.2, knitr 1.52, rmarkdown 2.32,
kableExtra 1.4.1, brms 2.23.0 and lme4 2.0-6. cmdstanr is the recorded
0.9.0.9000 GitHub commit `c57888e301416bf0cade86ae0d5540349c093593`.
Depends/Imports/LinkingTo are selected recursively; optional Suggests are not.
The legacy emo/devtools/targets/clustermq stack is excluded. brms's required
rstan/StanHeaders dependencies are included, but its dynamically generated
models are not precompiled.

renv 1.3.0 is **build-only**. Restore locked sources without host caches, macOS
binaries, pak, sandboxing or cache symlinks, then verify versions and Git SHAs.
Identical recommended packages supplied by the R base are copied into the course
library. No startup `restore()` or classroom `install.packages()` is needed.
Incompatible locked Linux packages fail the build rather than silently upgrading.
System dependencies are explicit in the Dockerfile; the unused sf/GDAL,
ImageMagick and ZMQ stacks are not added.

Matching sources load their image-built executable with `exe_file` and
`compile=FALSE`. Editing Stan code invalidates the executable and stored-result
route; the instructor must prepare a new image. This prevents stale code from
being used as the result of an edited model.

## Conservative classroom execution

Default: `AFEC_USE_PRECOMPUTED=TRUE`. Stored fits are valid only for their recorded
data/priors. Changed inputs are rejected in the classroom rather than returned
as a misleading comparison. When authorized by the instructor, use
`use_precomputed=FALSE, fallback=FALSE` for comparison tasks, retaining the model,
seed, chain count and iterations. Keep heavy/problematic fits precomputed.

Defaults are `parallel_chains=1`, `threads_per_chain=1`, one BLAS/OpenMP/
RcppParallel thread, and R `mc.cores=1`, `Ncpus=1`. The precompiled models support
threading but are run with one thread per chain. These defaults are **not hard
limits** on arbitrary student code; Compose must apply cgroup limits.

No 30-user performance claim is made. The i9-13900K's 32 logical threads are not
32 equivalent cores. Start with stored results and small groups for live fits.
A provisional cap of 1 CPU and 2–3 GiB per container needs single-user/small-group
measurement and adjustment. At 3 GiB each, 30 limits total 90 GiB, leaving part
of 128 GB for the OS, Docker and caches. OOM can still terminate R sessions or
sampling. Avoid simultaneous brms compilation and heavy fits. Draft QMD timing
estimates are not measurements on this shared server.

## Offline use and reproducibility

**Build network:** Docker Hub, Ubuntu apt, CRAN/Archive, GitHub (pinned cmdstanr,
CmdStan release and Stan logo), and npm registry (MathJax 3.2.2).
**Runtime:** no CRAN/GitHub/P3M download is needed for the core course. Do not bind
mount the old project with `INSIDE_CONTAINER=true` and its machine-specific profile.

Image-derived materials remove Google Fonts imports, bundle local Lato, use
fallbacks for other fonts, and bundle the Stan logo and MathJax. Repository
themes/QMDs are unchanged. The unused legacy `my_ggsave()` helper downloads a
Google font; do not call it in class. External reference links remain optional
reading, not bundled papers.

Slide HTML is rendered from existing fits during a future build. Exercises are
QMDs to open in RStudio and run chunk-by-chunk: worked solutions change data/prior
and cannot honestly be rendered from only default stored fits. If exercise HTML
is needed, the instructor must compute the changed conditions beforehand.
Keep HTML, its `*_files`, `assets` and `images` together. Offline browser rendering
of equations, figures and icons still requires acceptance testing.

Versions are pinned, but the base tag, apt distribution and logo's master URL are
mutable; bit-for-bit rebuilding is not guaranteed. Record and deploy the verified
completed **image digest** to all students. Pinning base digests/apt snapshots is
a follow-up after the first real build.

Build and validate where the required services are reachable, then transfer the
completed image to the classroom server (for example, `docker save` / `docker load`).
Do not depend on downloading or rebuilding it during the workshop in China.

## Future build and single-container example — not executed here

`fits/*.rds` is gitignored: cloning alone is insufficient. Supply all seven
validated fits under `fits/`, or the build deliberately fails. If necessary,
refit in the instructor environment using `Rscript R/precompute_fits.R`
(refits every course model), **not** `targets::tar_make()`.

```bash
# From the repository root on the Ubuntu Intel server
docker build --platform linux/amd64 --build-arg BUILD_JOBS=2 \
  -t afec-bayes:2026-r4.6.1 .

# Outside the repo: afec-student01.env contains PASSWORD=<unique strong password>
chmod 600 /srv/afec/secrets/afec-student01.env
docker volume create afec-student01-workspace
docker run -d --name afec-student01 \
  --env-file /srv/afec/secrets/afec-student01.env \
  -e ROOT=FALSE -e DISABLE_AUTH=FALSE \
  --cpus=1 --memory=3g --memory-swap=3g \
  --mount type=volume,source=afec-student01-workspace,target=/home/rstudio/workspace \
  -p 127.0.0.1:8787:8787 afec-bayes:2026-r4.6.1
```

Each container uses the login `rstudio`, a unique password and a unique volume.
Passwords are never baked into the image; Docker administrators can still inspect
runtime environment variables, so protect host administrative access.
Use a subsequent HTTPS reverse proxy or campus VPN, not public unencrypted ports.
Do not mount the Docker socket, host secrets or other students' volumes.
Do not bypass root initialization with a final `USER rstudio`, `--user rstudio`,
Compose `user: rstudio`, or an overridden entrypoint.

## Validation and outstanding risks

**The image was not built or started, as requested.** Local static/unit checks:

```bash
RENV_CONFIG_SANDBOX_ENABLED=FALSE Rscript docker/test-static.R
bash -n docker/00-afec-guard.sh
bash -n docker/03-afec-workspace.sh
git diff --check
```

Checks passed: R parsing, 156-package dependency closure, seven RDS/data checks,
changed-data/stale-source rejection, auth guards, and a first-copy/non-overwrite
file-operation simulation. The simulation stubs chown and macOS/GNU mv differences;
it is **not** proof of real Docker volume permissions or restart behavior.

A future build runs `verify.R` as `rstudio` to check locked package loading,
CmdStan, executable accessibility, stored fits, a short binomial sample and PNG
plotting. That hook has **not** been executed in an image. Its short sample tests
execution, not convergence or scientific adequacy. After building, run:

```bash
docker logs afec-student01
# Check required browser login, non-root R session and R 4.6.1
docker exec -u rstudio afec-student01 Rscript /opt/afec/bin/verify.R
docker exec -u rstudio afec-student01 sh -c \
  'echo persistence-test > /home/rstudio/workspace/afec-bayes-2026/persistence.txt'
docker restart afec-student01
docker exec -u rstudio afec-student01 cat \
  /home/rstudio/workspace/afec-bayes-2026/persistence.txt
```

Also test container **recreation** with the same volume, a fresh student volume,
real exercise chunks, student writes, model shared libraries and an outbound-blocked
network. Retain the classroom LAN for UI tests; `--network none` also prevents
browser access. Measure RSS/CPU/runtime before wider live sampling. Next prepare
30-container Compose, HTTPS, credential distribution, monitoring, backups and a
classroom rehearsal. A 30-user load test was not performed or required here.

Fits match the current seeded data, model names, CmdStan 2.38.0 and draw structure.
They were generated under R 4.5.3, whereas the current lock is R 4.6.1, and they
contain no Stan source digest. Exact generation-time source identity and full
refitting in the new Linux environment remain unverified. Recheck statistical
diagnostics before class; retain the deliberate bad fit as a labelled example.

Primary implementation references: [Rocker startup](https://github.com/rocker-org/rocker-versioned2/blob/master/scripts/install_rstudio.sh),
[renv restore](https://rstudio.github.io/renv/reference/restore.html),
[CmdStanR existing executables](https://mc-stan.org/cmdstanr/reference/cmdstan_model.html),
[Quarto local math library URL](https://quarto.org/docs/output-formats/html-basics.html#latex-equations).
