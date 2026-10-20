# Build only: do not source the project's machine-specific .Rprofile.
stopifnot(as.character(getRversion()) == "4.6.1")
options(
  repos = c(CRAN = "https://cloud.r-project.org"),
  timeout = 1200,
  Ncpus = 1L
)
Sys.setenv(
  RENV_CONFIG_CACHE_ENABLED = "FALSE",
  RENV_CONFIG_PAK_ENABLED = "FALSE",
  RENV_CONFIG_SANDBOX_ENABLED = "FALSE",
  RENV_CONFIG_AUTOLOADER_ENABLED = "FALSE",
  RENV_CONFIG_INSTALL_SHORTCUTS = "FALSE",
  RENV_CONFIG_INSTALL_JOBS = "1",
  RENV_CONFIG_SYSREQS_CHECK = "FALSE",
  RENV_CONFIG_PPM_ENABLED = "FALSE",
  RENV_CONFIG_INSTALL_REMOTES = "FALSE",
  RENV_CONFIG_AUTO_SNAPSHOT = "FALSE",
  MAKEFLAGS = paste0("-j", Sys.getenv("BUILD_JOBS", "2"))
)
bootstrap <- "/opt/afec/build/bootstrap"
dir.create(bootstrap, recursive = TRUE)
archive <- tempfile(fileext = ".tar.gz")
# Bootstrap exactly the renv recorded in the main lock, not CRAN's latest.
download.file(
  "https://cran.r-project.org/src/contrib/Archive/renv/renv_1.3.0.tar.gz",
  archive,
  mode = "wb"
)
install.packages(archive, repos = NULL, type = "source", lib = bootstrap)
.libPaths(c(bootstrap, .libPaths()))
stopifnot(as.character(packageVersion("renv")) == "1.3.0")
lock <- renv::lockfile_read("/opt/afec/renv.lock")
stopifnot(
  lock$R$Version == as.character(getRversion()),
  lock$Packages$renv$Version == "1.3.0"
)
source("/opt/afec/build/package-plan.R")
packages <- package_plan(lock)
lock$Packages <- lock$Packages[packages]
for (name in packages) {
  record <- lock$Packages[[name]]
  if (!is.null(record$RemoteSha)) {
    record$RemoteRef <- record$RemoteSha
  }
  lock$Packages[[name]] <- record
}
renv::lockfile_write(lock, "/opt/afec/classroom.lock")
lib <- "/opt/afec/library"
dir.create(lib, recursive = TRUE)
renv::restore(
  project = "/opt/afec/build",
  library = lib,
  lockfile = lock,
  packages = packages,
  repos = getOption("repos"),
  prompt = FALSE
)
for (name in packages) {
  # restore(library=...) also sees R's recommended library. If an identical
  # recommended package is supplied by the base image, copy it into the shared
  # course library so runtime lookup and version verification stay unambiguous.
  if (!file.exists(file.path(lib, name, "DESCRIPTION"))) {
    base_path <- find.package(name, lib.loc = .Library)
    stopifnot(
      packageDescription(name, lib.loc = .Library)$Version ==
        lock$Packages[[name]]$Version,
      file.copy(base_path, lib, recursive = TRUE)
    )
  }
  actual <- packageDescription(name, lib.loc = lib)
  stopifnot(identical(actual$Version, lock$Packages[[name]]$Version))
  sha <- lock$Packages[[name]]$RemoteSha
  if (!is.null(sha)) stopifnot(identical(actual$RemoteSha, sha))
}
write.table(
  data.frame(
    package = packages,
    version = vapply(lock$Packages, `[[`, "", "Version")
  ),
  "/opt/afec/packages.tsv",
  row.names = FALSE,
  quote = FALSE,
  sep = "\t"
)
writeLines(course_packages, "/opt/afec/course-packages.txt")
unlink(archive)
