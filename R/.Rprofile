# R Profile - loaded on R startup
# This file is symlinked to ~/.Rprofile

# Set default CRAN mirror - use Posit Package Manager for all platforms
# PPM provides pre-compiled binaries and fast CDN delivery
# Fall back to CRAN source packages if binaries aren't available
# Setting HTTPUserAgent ensures R requests binary packages instead of source
if (Sys.info()["sysname"] == "Linux") {
  # Linux: Use PPM with Ubuntu 22.04 (Jammy) binaries, fall back to CRAN source
  options(
    repos = c(
      PPM = "https://packagemanager.posit.co/cran/__linux__/jammy/latest",
      CRAN = "https://cloud.r-project.org"
    ),
    HTTPUserAgent = sprintf("R/%s R (%s)", getRversion(), paste(getRversion(), R.version$platform, R.version$arch, R.version$os))
  )
} else {
  # macOS and Windows: Use PPM latest (serves CRAN binaries), fall back to CRAN
  options(
    repos = c(
      PPM = "https://packagemanager.posit.co/cran/latest",
      CRAN = "https://cloud.r-project.org"
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
if (interactive()) {
  tryCatch({
    loadNamespace("httpgd")
    options(device = function(...) {
      httpgd::hgd(port = 35211, silent = TRUE)
    })
  }, error = function(e) {
    # httpgd not available, skip graphics device setup
  })
}

cat("R profile loaded from dotfiles\n")
cat("→ Using Posit Package Manager for fast binary installations\n")
