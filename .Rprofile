# ==============================================================================
# 1. Network & Proxy Settings (Earliest possible for renv/activate.R)
# ==============================================================================
if (identical(Sys.info()[["sysname"]], "Darwin") && Sys.getenv("INSIDE_CONTAINER") != "true") {
  # Keep the renv package cache in a user-controlled location on macOS.
  Sys.setenv(RENV_PATHS_CACHE = path.expand("~/renv"))
}

if (Sys.getenv("INSIDE_CONTAINER") == "true") {

  nodename <- Sys.info()[["nodename"]]

  if (identical(nodename, "big-nose")) {
    # --- Linux (big-nose / sing-box) ---
    Sys.setenv(
      http_proxy  = "http://127.0.0.1:2080",
      https_proxy = "http://127.0.0.1:2080"
    )
  } else {
    # --- Mac Docker Shadowrocket ---
    Sys.setenv(
      http_proxy  = "http://host.docker.internal:1082",
      https_proxy = "http://host.docker.internal:1082",
      ALL_PROXY   = "socks5://host.docker.internal:1081"
    )
  }

  # pak error
  Sys.setenv(PAK_BIND_MOUNTS = "1")
}

# ==============================================================================
# 2. Global Configuration
# ==============================================================================
# Only expose the container's site library when it actually exists.
container_site_lib <- "/usr/local/lib/R/site-library"
options(
  renv.config.external.libraries =
    if (Sys.getenv("INSIDE_CONTAINER") == "true" && dir.exists(container_site_lib))
      container_site_lib else NULL,
  renv.config.install.prefer.binaries = TRUE,
  # Respect explicit configuration; use pak by default only in the container.
  renv.config.pak.enabled = tolower(Sys.getenv(
    "RENV_CONFIG_PAK_ENABLED",
    unset = as.character(Sys.getenv("INSIDE_CONTAINER") == "true")
  )) %in% c("true", "t", "1"),
  Ncpus = parallel::detectCores(),
  timeout = 600
)

P3M_DATE <- "2026-10-01"
os_info <- Sys.info()[["sysname"]]

# ==============================================================================
# 3. Repository Logic
# ==============================================================================
set_repos <- function(cran_url) {
  repos <- c(
    rOpenSci = "https://ropensci.r-universe.dev",
    Stan     = "https://stan-dev.r-universe.dev",
    CRAN     = cran_url
  )
  options(repos = repos)
  options(renv.config.repos.override = repos)
}

if (os_info == "Linux") {
  if (file.exists("/etc/os-release")) {
    os_release_data <- readLines("/etc/os-release")
    get_val <- function(key) {
      line <- os_release_data[grep(paste0("^", key, "="), os_release_data)]
      if (length(line) > 0) return(gsub('"', '', sub(paste0("^", key, "="), "", line)))
      return(NULL)
    }
    distro <- get_val("ID")
    codename <- get_val("VERSION_CODENAME")

    if (!is.null(distro) && distro == "ubuntu" && !is.null(codename)) {
      set_repos(sprintf("https://p3m.dev/cran/__linux__/%s/%s", codename, P3M_DATE))
    } else {
      set_repos(sprintf("https://p3m.dev/cran/%s", P3M_DATE))
    }
  }
} else {
  set_repos(sprintf("https://p3m.dev/cran/%s", P3M_DATE))
}

# ==============================================================================
# 4. Activation & Library Path Fix
# ==============================================================================
if (file.exists("renv/activate.R")) {
  source("renv/activate.R")

  if (identical(os_info, "Darwin") && Sys.getenv("INSIDE_CONTAINER") != "true" &&
      requireNamespace("renv", quietly = TRUE)) {
    project_lib <- renv::paths$library()
    if (dir.exists(project_lib) && !project_lib %in% .libPaths()) {
      .libPaths(c(project_lib, .libPaths()))
    }
  }

  if (Sys.getenv("INSIDE_CONTAINER") == "true") {
    site_lib <- "/usr/local/lib/R/site-library"
    if (dir.exists(site_lib)) {
      .libPaths(unique(c(.libPaths(), site_lib)))
    }
  }
}

# ==============================================================================
# 5. Tooling Integration (VSCode / Stan)
# ==============================================================================
if (interactive() && Sys.getenv("TERM_PROGRAM") == "vscode") {
  vscode_init <- c(Sys.getenv("VSCODE_INIT_R"), file.path("~", ".vscode-R", "init.R"))
  vscode_init <- path.expand(vscode_init[nzchar(vscode_init)])
  vscode_init <- vscode_init[file.exists(vscode_init)]
  if (length(vscode_init)) {
    source(vscode_init[[1]], chdir = TRUE, local = TRUE)
  }
}

if (Sys.getenv("INSIDE_CONTAINER") == "true") {
  cmdstan_path <- Sys.getenv("CMDSTAN_PATH", unset = NA)
  if (!is.na(cmdstan_path) && requireNamespace("cmdstanr", quietly = TRUE)) {
    cmdstanr::set_cmdstan_path(cmdstan_path)
  }
}
