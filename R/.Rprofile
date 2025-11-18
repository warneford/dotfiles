# R Profile - loaded on R startup
# This file is symlinked to ~/.Rprofile

# Save reference to base install.packages before overwriting
.base_install_packages <- utils::install.packages

# Wrapper for install.packages() that tries conda first, then falls back to CRAN
# Only active on Linux - macOS uses CRAN validated binaries for reliability
install.packages <- function(pkgs, ...) {
  # Use saved reference to base install.packages
  base_install <- .base_install_packages

  # Only use conda on Linux (macOS should use CRAN validated binaries)
  is_linux <- Sys.info()["sysname"] == "Linux"

  if (!is_linux) {
    # On macOS, use CRAN directly for validated binaries
    return(base_install(pkgs, ...))
  }

  # Check if we're in a conda environment
  conda_prefix <- Sys.getenv("CONDA_PREFIX")
  has_mamba <- Sys.which("mamba") != ""

  if (conda_prefix == "" || !has_mamba) {
    # Not in conda environment or mamba not available, use CRAN directly
    return(base_install(pkgs, ...))
  }

  # Convert R package names to conda package names
  # R packages use dots, conda uses hyphens and lowercase
  conda_pkgs <- paste0("r-", tolower(gsub("\\.", "-", pkgs)))

  cat("Attempting to install via conda:", paste(pkgs, collapse = ", "), "\n")

  # Try conda installation for each package
  installed_via_conda <- character(0)
  failed_conda <- character(0)

  for (i in seq_along(pkgs)) {
    pkg <- pkgs[i]
    conda_pkg <- conda_pkgs[i]

    # Try installing with mamba (suppresses output unless there's an error)
    result <- system2("mamba",
                     c("install", "-y", "-q", conda_pkg),
                     stdout = FALSE,
                     stderr = FALSE)

    if (result == 0) {
      installed_via_conda <- c(installed_via_conda, pkg)
    } else {
      failed_conda <- c(failed_conda, pkg)
    }
  }

  # Report conda installations
  if (length(installed_via_conda) > 0) {
    cat("✓ Installed via conda:", paste(installed_via_conda, collapse = ", "), "\n")
  }

  # Fall back to CRAN for packages that failed with conda
  if (length(failed_conda) > 0) {
    cat("→ Installing from CRAN:", paste(failed_conda, collapse = ", "), "\n")
    base_install(failed_conda, ...)
  }

  invisible(NULL)
}

# Set default CRAN mirror
options(repos = c(CRAN = "https://cloud.r-project.org"))

# Google authentication settings for gargle/googledrive/googlesheets4
options(
  gargle_oauth_cache = file.path(Sys.getenv("HOME"), ".secrets"),
  gargle_oauth_email = "robert@octant.bio",
  browser = function(url) {
    message("Please open this URL in your browser:\n", url)
  }
)

# Disable automatic package loading messages for cleaner startup
options(defaultPackages = c(getOption("defaultPackages"), "stats", "graphics", "grDevices", "utils", "datasets", "methods", "base"))

cat("R profile loaded from dotfiles\n")
if (Sys.info()["sysname"] == "Linux") {
  cat("→ install.packages() will try conda first, then fall back to CRAN\n")
} else {
  cat("→ install.packages() will use CRAN validated binaries\n")
}
