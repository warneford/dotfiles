# R Profile - loaded on R startup
# This file is symlinked to ~/.Rprofile

# Ensure personal library exists and is used by default
# This avoids the "Would you like to use a personal library?" prompt
# Uses R's default structure: ~/R/{platform}-library/{major.minor}/
# e.g., ~/R/x86_64-pc-linux-gnu-library/4.5/
# Minor versions can break ABI compatibility, so we version by major.minor
local({
  r_version <- paste0(R.version$major, ".", strsplit(R.version$minor, "\\.")[[1]][1])
  platform_lib <- paste0(R.version$platform, "-library")
  lib_path <- file.path(Sys.getenv("HOME"), "R", platform_lib, r_version)
  if (!dir.exists(lib_path)) {
    dir.create(lib_path, recursive = TRUE)
  }
  # Ensure user library is FIRST (radian/rchitect may initialize paths differently)
  # Remove any existing instance to avoid duplicates, then prepend
  current_paths <- .libPaths()
  current_paths <- current_paths[current_paths != lib_path]
  .libPaths(c(lib_path, current_paths))
})

# Set default CRAN mirror - use Posit Package Manager for all platforms
# PPM provides pre-compiled binaries and fast CDN delivery
# Fall back to CRAN source packages if binaries aren't available
# Setting HTTPUserAgent ensures R requests binary packages instead of source
if (Sys.info()["sysname"] == "Linux") {
  # Linux: Use PPM binaries matching the current distro
  # Detect Ubuntu codename from /etc/os-release
  distro_codename <- tryCatch({
    os_release <- readLines("/etc/os-release", warn = FALSE)
    codename_line <- grep("^VERSION_CODENAME=", os_release, value = TRUE)
    if (length(codename_line) > 0) {
      sub("^VERSION_CODENAME=", "", codename_line)
    } else {
      "jammy"  # fallback
    }
  }, error = function(e) "jammy")

  ppm_url <- paste0("https://packagemanager.posit.co/cran/__linux__/", distro_codename, "/latest")

  options(
    repos = c(
      PPM = ppm_url,
      CRAN = "https://cloud.r-project.org"
    ),
    HTTPUserAgent = sprintf("R/%s R (%s)", getRversion(), paste(getRversion(), R.version$platform, R.version$arch, R.version$os))
  )
} else {
  # macOS and Windows: Use CRAN official binaries (better R 4.5+ compatibility)
  # PPM binaries have linking issues with R 4.5+ and radian
  options(
    repos = c(
      CRAN = "https://cloud.r-project.org",
      PPM = "https://packagemanager.posit.co/cran/latest"
    ),
    HTTPUserAgent = sprintf("R/%s R (%s)", getRversion(), paste(getRversion(), R.version$platform, R.version$arch, R.version$os))
  )
}

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

# Auto-start httpgd for interactive sessions (web-based graphics viewer)
# Access plots at http://localhost:35211 (requires SSH port forwarding)
# Token disabled since we're behind VPN
if (interactive()) {
  invisible(tryCatch({
    loadNamespace("httpgd")
    options(
      httpgd.port = 35211,
      httpgd.token = FALSE
    )
    # Only start httpgd if not already running
    if (!httpgd::hgd_active()) {
      httpgd::hgd()
    }
  }, error = function(e) {
    # httpgd not available, skip graphics device setup
    invisible(NULL)
  }))
}

cat("R profile loaded from dotfiles\n")
cat("→ Using CRAN official binaries (PPM fallback)\n")
