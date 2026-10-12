# Only runtime/compile dependencies; no Suggests or legacy targets/devtools stack.
course_packages <- c(
  "tidyverse", "posterior", "bayesplot", "patchwork", "here", "knitr",
  "rmarkdown", "kableExtra", "cmdstanr", "brms", "lme4", "loo"
)

package_plan <- function(lock) {
  packages <- course_packages
  base_packages <- rownames(installed.packages(priority = "base"))
  repeat {
    if (length(setdiff(packages, names(lock$Packages))))
      stop("A requested course package is absent from renv.lock")
    deps <- unique(unlist(lapply(lock$Packages[packages], function(record) {
      fields <- as.character(unlist(record[c("Depends", "Imports", "LinkingTo")]))
      fields <- trimws(unlist(strsplit(fields, ",", fixed = TRUE)))
      sub("[[:space:](].*$", "", fields)
    })))
    missing <- setdiff(deps, c("R", base_packages, names(lock$Packages)))
    if (length(missing)) stop("Unlocked dependencies: ", paste(missing, collapse = ", "))
    next_packages <- union(packages, intersect(deps, names(lock$Packages)))
    if (length(next_packages) == length(packages)) break
    packages <- next_packages
  }
  sort(packages)
}
