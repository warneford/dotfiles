# R Profile - loaded on R startup
# This file is symlinked to ~/.Rprofile

# Set default CRAN mirror - use Posit Package Manager for all platforms
# PPM provides pre-compiled binaries and fast CDN delivery
# Setting HTTPUserAgent ensures R requests binary packages instead of source
if (Sys.info()["sysname"] == "Linux") {
  # Linux: Use PPM with Ubuntu 22.04 (Jammy) binaries
  options(
    repos = c(CRAN = "https://packagemanager.posit.co/cran/__linux__/jammy/latest"),
    HTTPUserAgent = sprintf("R/%s R (%s)", getRversion(), paste(getRversion(), R.version$platform, R.version$arch, R.version$os))
  )
} else {
  # macOS and Windows: Use PPM latest (serves CRAN binaries)
  options(
    repos = c(CRAN = "https://packagemanager.posit.co/cran/latest"),
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

cat("R profile loaded from dotfiles\n")
cat("→ Using Posit Package Manager for fast binary installations\n")
