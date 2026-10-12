# 2026-10-12 handoff: Compose deployment and optional local participation

Follows `2026-10-12-classroom-docker.md`. This log supersedes its statement
that Compose is still to be prepared; the image/runtime validation remains open.

## Goal

Prepare 30 independent RStudio Server services using the shared classroom image,
without building the image or starting containers. Discuss optional local R use
for participants who can prepare their environment before class.

## Current state

- Compose, credential generation and English documentation are complete.
- Git was clean before this log. Existing commits are `a130704` (`add docker`)
  and `66f1cb8` (`add docker-compose`); no commit or push was made by the agent.
- **No image build, pull, container startup, network or volume creation was
  performed.** Do not treat static checks as runtime acceptance.
- Hybrid participation was recommended, not implemented or finally approved.
  No new local setup instructions or pre-course verification task were created.

## Decisions and reasoning

- Define fixed `student01`–`student30` services, not anonymous scaled replicas,
  to preserve individual credentials, endpoints and named workspaces.
- Use one prebuilt amd64 image (`afec-bayes:2026-r4.6.1` by default), no Compose
  build section and `pull_policy: never`. Keep Rocker's root `/init` startup;
  student R sessions remain non-root with authentication and `ROOT=FALSE`.
- Publish ports 8801–8830 on localhost by default. A host HTTPS proxy or campus
  VPN is still needed for secure remote access; no proxy/TLS setup was added.
- Persist only `/home/rstudio/workspace`, using one named volume per student.
  Keep project name `afec-bayes-2026` stable. Do not use `down --volumes` when
  student work must be retained.
- Provisional limits are 1 CPU, 3 GiB memory, no additional swap and 256 processes
  per container, with single-thread defaults and stored fits enabled. These are
  upper limits, not a demonstrated capacity for 30 simultaneous fits.
- Use one classroom bridge with `enable_icc=false` rather than 30 subnet
  allocations. Actual firewall enforcement is untested; this does not block
  outbound internet or guarantee isolation against hostile code/host endpoints.
- Generate independent passwords into private env files (directory 0700,
  files 0600), preserve existing files on reruns, and do not print passwords.
  Exclude runtime credentials from Git and the image build context.

## Hybrid participation proposal

- Default to RStudio Server; permit local execution only after a pre-course
  check, suggested one week before class. Installation is not a requirement.
- Check package loading, exercise data, stored-RDS analysis and plotting.
  Local live inference additionally needs verified CmdStan compilation/sampling
  and a suitable C++ toolchain.
- Use the same teaching materials, data and stored fits in both environments;
  align the documented software versions. Complete downloads before class in
  China. Switch to Server when local problems arise instead of troubleshooting
  installation during teaching time.
- Prepare Server credentials for all 30 participants, including local users.
  Local use may reduce typical load, but do not assume fallback demand is lower
  than 30 or that the untested server can support unrestricted live fitting.

## Files changed in the Compose work

- Added `docker-compose.yml`, `.env.example`, `docker/create-student-env.sh`.
- Updated `.gitignore`, `.dockerignore` to protect local configuration/secrets.
- Updated `README.md` and `docker/README.md` in English with deployment,
  credential handling, networking, persistence and validation instructions.
- No R/Stan models, statistical settings, fits or course materials were changed
  during the Compose work or the subsequent hybrid consultation.

## Validation

Passed with Docker Compose v5.1.2, without Docker daemon operations:

```bash
docker compose config --no-env-resolution --quiet
bash -n docker/create-student-env.sh
git diff --check
```

Additional temporary Ruby checks parsed canonical Compose JSON and checked all
30 service/port/credential/volume mappings, resource/auth/thread defaults,
inherited startup and the final bridge option. Temporary credential tests checked
30 unique passwords, private permissions, preservation of edited/existing files,
full `config --quiet` validation and rejection of missing credential files.
The temporary test credentials were removed; production credentials were not
generated. Git ignore checks covered `.env` and student env files.

## Unresolved and next steps

- Respect the **do-not-build / do-not-start** instruction until new authorization.
- Review the proposed hybrid policy and prepare a short pre-course check plus
  optional local instructions; Windows/Linux local environments are unverified.
- Once authorized, build on Ubuntu amd64 and validate one fresh participant:
  login, R/package/CmdStan versions, model execution, plotting, offline assets,
  workspace writes and persistence after restart AND recreation.
- Validate HTTPS/VPN access and bridge/firewall behavior; measure memory/CPU and
  exercise runtime before deciding how many students may fit models concurrently.
- Prepare credential distribution, volume backups, monitoring and a rehearsal.
  No 30-user load test has been performed; capacity and OOM risks remain unknown.

## Best next action

Agree on the pre-course readiness check and Server fallback policy. Do not redo
the Compose implementation or refit course models merely to repeat static
checks. Plan the target-server acceptance test for when building is authorized.
