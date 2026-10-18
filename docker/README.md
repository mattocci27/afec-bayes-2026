# AFEC 2026 classroom Docker image

One image supplies 30 independent RStudio Server containers on the Ubuntu Intel
server. The root `docker-compose.yml` defines 30 student services with individual
credentials, volumes, ports and resource limits.

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

Day 2 core work uses stored results; all core tasks also have a figure-reading
route. Its brms fitting chunk is optional reference with `eval=FALSE`. It does not
use the image's handwritten-Stan executables. Any instructor demonstration requires
separate validation of compilation, sampling, diagnostics and plotting in advance;
existing executable checks do not validate it. Students are not required to test
compilation or fitting before class. See [student setup](../classroom/PACKAGES.md).

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

Slides and static handouts are rendered from existing fits during future builds.
`R/classroom_materials.R` removes solution Divs from participant QMDs before
execution. Open `exercise-student.qmd` chunk-by-chunk, or use its HTML together
with `results.html` during connectivity problems. Changed-input inference chunks
are disabled during rendering and need explicit live flags. Historical values
are labelled; default fits are never substituted for changed-input posteriors.
`classroom/readiness.html` checks login, stored-fit analysis, plotting and local
handouts before class. Existing built images and student volumes are not updated
by these source changes; supply the revised ZIP in a new course directory or
plan an image/workspace migration after backing up participant work.
Keep HTML, its `*_files`, `assets` and `images` together. Offline browser rendering
of equations, figures and icons still requires acceptance testing.

Versions are pinned, but the base tag, apt distribution and logo's master URL are
mutable; bit-for-bit rebuilding is not guaranteed. Record and deploy the verified
completed **image digest** to all students. Pinning base digests/apt snapshots is
a follow-up after the first real build.

Build and validate where the required services are reachable, then transfer the
completed image to the classroom server (for example, `docker save` / `docker load`).
Do not depend on downloading or rebuilding it during the workshop in China.

## Build and single-container example

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

## Compose deployment — prepared, not started

All services use the same prebuilt image, defaulting to `afec-bayes:2026-r4.6.1`.
There is no `build` section and `pull_policy: never` prevents an unexpected image
download during class. Build/load and validate the image separately before use.
Rocker's root startup and `/init` are inherited.

| Setting | Default |
|---|---|
| Services | `student01`–`student30` |
| Host ports | `8801`–`8830`, in student order; container port `8787` |
| Host bind address | `127.0.0.1` |
| Username | `rstudio` inside each independent container |
| Password file | `.afec-credentials/studentNN.env` |
| Persistent storage | One named `studentNN-workspace` volume per student |
| Mount target | `/home/rstudio/workspace` only |
| CPU / memory / swap | 1 CPU / 3 GiB / no additional swap per container |
| Process limit | 256 per container |
| Network | One classroom bridge; direct inter-container connectivity disabled |
| Restart / health | `unless-stopped`; local HTTP check every 30 seconds |

The CPU/memory settings are provisional upper limits, not reserved capacity or
a guarantee of 30 simultaneous fits. One bridge avoids allocating 30 subnets.
Docker's [bridge driver option](https://docs.docker.com/engine/network/drivers/bridge/#options)
`enable_icc=false` disables direct inter-container connectivity. It does not
disable internet access or guarantee isolation against hostile code or access
through published host endpoints. Validate the host's firewall/routing before
class. The core course needs no outbound downloads.

Run the following **later**, once the image is ready:

```bash
# Generate 30 unique passwords without displaying them; reruns keep existing files.
bash docker/create-student-env.sh
# Validate including credential files without printing their contents.
docker compose config --quiet

# First validate one new student, then start all 30 after acceptance.
docker compose up -d --no-build student01
docker compose ps student01
docker compose logs --tail=50 student01
docker compose exec --user rstudio student01 Rscript /opt/afec/bin/verify.R
docker compose up -d --no-build

# Target one student without interrupting the others.
docker compose restart student01
docker compose stop student01
```

The credential helper requires host `openssl`. It creates a private directory
(0700) and individual env files (0600). Distribute each student's password and
endpoint individually. Existing files are preserved, including intentionally
edited passwords; change a password by editing its file and recreating that
service with `docker compose up -d --no-build --force-recreate student01`.
The workspace volume persists. A plain restart does not reload an edited env file.
Do not print or publish plain `docker compose config`: it resolves passwords.
Use `--quiet`, or `--no-env-resolution` for a credential-free structural check.

For optional host-specific settings, copy `.env.example` to `.env` only if `.env`
does not already exist. Configure `AFEC_IMAGE`, `AFEC_CREDENTIALS_DIR`,
`AFEC_BIND_IP`, `AFEC_CPUS` and `AFEC_MEMORY_LIMIT` there. The credential helper
uses its explicit argument, not Compose's `.env`; for a custom directory, run
`bash docker/create-student-env.sh /dedicated/credentials-directory` and set
`AFEC_CREDENTIALS_DIR` to that absolute directory. Credentials and `.env` are
Git-ignored, and credential files are excluded from the image build context.

Default endpoints are `http://127.0.0.1:8801` through `:8830` **on the server**.
Remote students cannot reach that loopback address directly. Use a host HTTPS
reverse proxy to route individual student hostnames to these ports. No proxy or
TLS configuration is included yet. For a trusted classroom LAN test, set
`AFEC_BIND_IP` to the server's LAN IPv4 address and allow ports 8801–8830 on that
LAN; endpoints then become `http://<server-LAN-IP>:8801`, etc. This direct route
is unencrypted; prefer HTTPS or an encrypted VPN for actual credential use.

Compose names volumes using the fixed project name `afec-bayes-2026`. Keep that
name stable: changing `-p`/`COMPOSE_PROJECT_NAME` selects different volumes.
`docker compose down` keeps named volumes; `down --volumes` deletes student work.
Back up the volumes before image/host maintenance. A container's IDE settings
outside the workspace are still lost on recreation. Health checks only test the
HTTP server; they do not validate a student's R session, and unhealthy status
alone does not trigger automatic recreation.

## Validation and outstanding risks

### Build and runtime acceptance: 2026-10-12

The image built successfully using the command above on Linux amd64. The final
successful build took 1,371.14 seconds (22 minutes 51 seconds), including a
temporary stall downloading the Stan logo. The initial preflight was blocked by
seven missing RDS files; these were subsequently supplied without model refitting.

Preflight commands: `docker version`, `docker buildx version`,
`docker compose version`, `uname -m`, `df -h . /tmp`, `free -h`, and `ls -lh fits`.
Docker client/server were both 29.9.0, Buildx was 0.38.0, and Compose was 5.6.0.
The host was x86_64, with 476 GB of available disk space and 121 GiB of available
memory (125 GiB total).

Two fixes were required: set `R_LIBS=/opt/afec/library` to override Rocker's
default library precedence (which selected readxl 1.5.0 instead of the locked
1.5.0.1), and compare DESCRIPTION versions directly because `packageVersion()`
normalizes versions such as abind's `1.4-8` to `1.4.8`. Verification now checks
library precedence and reports the package, expected/actual versions and path
on a mismatch. The locked package versions were preserved. Buildx also needed
a private temporary `DOCKER_CONFIG` because the session's `~/.docker` was
read-only; the temporary configuration was removed after each attempt.

Image tag: `afec-bayes:2026-r4.6.1`.
Image ID: `sha256:49b6d761a33e95240f54e55ad7341da564a4f32b0c1eee0650ed5920f2cb30a9`.
Image size: 6,658,389,171 bytes (6.66 GB). No repository digest is available for
this locally built image; it was not pushed. The base image repository digest
was `sha256:94a4cdb7be4d1214f9039bca4937e8919253d2ad90d8bed084e9a8af685a50c7`.
Runtime versions: R 4.6.1, CmdStan 2.38.0 and Quarto 1.10.18.

All three slide decks rendered. The build-time and runtime `verify.R` checks
passed as `rstudio`, including all 156 locked package versions, seven stored
fits, 13 model executables, two short sequential binomial chains (100 retained
draws total), and PNG plotting. The short sample validates execution only.

A unique temporary container used a fresh named workspace volume, a private
runtime password file, localhost-only port binding, a 1 CPU limit and 3 GiB
memory limit. RStudio served the sign-in page with a browser user agent.
Non-root file writes succeeded, and a marker survived both restart and container
recreation with the same volume. The temporary container, volume and password
file were removed. Existing student services and credentials were not changed.

Build logs, exit codes, durations, image inspection and runtime commands/results
are in [`../logs/docker-build-2026-10-12/`](../logs/docker-build-2026-10-12/).
Browser login, visual/offline browser inspection, a fresh interactive RStudio
session and 30-user load testing remain unverified. No registry push or external
deployment was performed.

### Earlier static validation

**The image was not built or started during the earlier implementation.** Local static/unit checks:

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

A build runs `verify.R` as `rstudio` to check locked package loading,
CmdStan, executable accessibility, stored fits, a short binomial sample and PNG
plotting. That hook passed in the image described above. Its short sample tests
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
HTTPS, credential distribution, monitoring, backups and a
classroom rehearsal. A 30-user load test was not performed or required here.

Compose was parsed with Docker Compose v5.1.2 using
`docker compose config --no-env-resolution --quiet`, without contacting the
Docker daemon or creating images, containers, networks or volumes. Static checks
cover 30 distinct ports, credential paths and workspace volumes, the bridge
configuration, resource limits, auth/thread defaults and preserved `/init` startup. The credential
helper was checked in a temporary directory for 30 unique private files and
non-overwrite behavior. Server-side limits, HTTP health checks, network routing
and routing still require classroom acceptance. Single-container HTTP startup
and workspace persistence passed in the runtime check described above.

Fits match the current seeded data, model names, CmdStan 2.38.0 and draw structure.
They were generated under R 4.5.3, whereas the current lock is R 4.6.1, and they
contain no Stan source digest. Exact generation-time source identity and full
refitting in the new Linux environment remain unverified. Recheck statistical
diagnostics before class; retain the deliberate bad fit as a labelled example.

Primary implementation references: [Rocker startup](https://github.com/rocker-org/rocker-versioned2/blob/master/scripts/install_rstudio.sh),
[renv restore](https://rstudio.github.io/renv/reference/restore.html),
[CmdStanR existing executables](https://mc-stan.org/cmdstanr/reference/cmdstan_model.html),
[Quarto local math library URL](https://quarto.org/docs/output-formats/html-basics.html#latex-equations).
