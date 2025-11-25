#!/bin/bash

# Install R from source on Linux without root access
# Installs to ~/.local/R/<version> with a 'current' symlink

set -e

# Configuration
R_VERSION="${R_VERSION:-4.5.1}"
R_INSTALL_DIR="$HOME/.local/R"
R_PREFIX="$R_INSTALL_DIR/$R_VERSION"
BUILD_DIR="$HOME/tmp/R-build"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }
print_info() { echo -e "${YELLOW}→${NC} $1"; }

# Check for required build tools
check_dependencies() {
    local missing=()

    command -v gcc &> /dev/null || missing+=("gcc")
    command -v gfortran &> /dev/null || missing+=("gfortran")
    command -v make &> /dev/null || missing+=("make")
    command -v curl &> /dev/null || missing+=("curl")

    if [ ${#missing[@]} -ne 0 ]; then
        print_error "Missing required build tools: ${missing[*]}"
        echo ""
        echo "On Ubuntu/Debian (requires root):"
        echo "  sudo apt install build-essential gfortran libreadline-dev libcurl4-openssl-dev"
        echo ""
        echo "On RHEL/CentOS/Rocky (requires root):"
        echo "  sudo dnf install gcc gcc-gfortran make readline-devel libcurl-devel"
        echo ""
        echo "If you don't have root, ask your sysadmin to install these, or check if"
        echo "they're available via 'module load' on your HPC system."
        exit 1
    fi

    print_success "Build tools found: gcc, gfortran, make, curl"
}

# Check for optional but recommended libraries
check_optional_deps() {
    print_info "Checking optional dependencies..."

    # Check for readline (better REPL experience)
    if ! ldconfig -p 2>/dev/null | grep -q libreadline || \
       ! [ -f /usr/include/readline/readline.h ] 2>/dev/null; then
        print_info "libreadline-dev not found - R will build without readline support"
    fi

    # Check for libcurl (needed for downloading packages)
    if ! ldconfig -p 2>/dev/null | grep -q libcurl; then
        print_info "libcurl not found - install.packages() may not work"
    fi
}

# Download R source
download_r() {
    local r_url="https://cran.r-project.org/src/base/R-${R_VERSION%%.*}/R-${R_VERSION}.tar.gz"
    local tarball="$BUILD_DIR/R-${R_VERSION}.tar.gz"

    mkdir -p "$BUILD_DIR"

    if [ -f "$tarball" ]; then
        print_success "R source tarball already downloaded"
    else
        print_info "Downloading R ${R_VERSION} from CRAN..."
        curl -L "$r_url" -o "$tarball"
        print_success "Downloaded R-${R_VERSION}.tar.gz"
    fi

    # Extract
    print_info "Extracting source..."
    cd "$BUILD_DIR"
    tar -xzf "$tarball"
    print_success "Source extracted"
}

# Configure and build R
build_r() {
    cd "$BUILD_DIR/R-${R_VERSION}"

    print_info "Configuring R (this may take a minute)..."

    # Configure flags:
    # --prefix: install location
    # --enable-R-shlib: build shared library (needed for RStudio, some packages)
    # --with-x=no: don't require X11 (for headless servers)
    # --enable-memory-profiling: useful for debugging
    ./configure \
        --prefix="$R_PREFIX" \
        --enable-R-shlib \
        --with-x=no \
        --enable-memory-profiling \
        2>&1 | tee configure.log

    if [ ${PIPESTATUS[0]} -ne 0 ]; then
        print_error "Configure failed. Check $BUILD_DIR/R-${R_VERSION}/configure.log"
        exit 1
    fi
    print_success "Configuration complete"

    # Detect number of CPU cores for parallel build
    local cores=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 2)

    print_info "Building R with ${cores} cores (this takes 10-15 minutes)..."
    make -j"$cores" 2>&1 | tee build.log

    if [ ${PIPESTATUS[0]} -ne 0 ]; then
        print_error "Build failed. Check $BUILD_DIR/R-${R_VERSION}/build.log"
        exit 1
    fi
    print_success "Build complete"
}

# Install R
install_r() {
    cd "$BUILD_DIR/R-${R_VERSION}"

    print_info "Installing R to $R_PREFIX..."
    make install 2>&1 | tee install.log

    if [ ${PIPESTATUS[0]} -ne 0 ]; then
        print_error "Install failed. Check $BUILD_DIR/R-${R_VERSION}/install.log"
        exit 1
    fi
    print_success "R installed to $R_PREFIX"

    # Create/update 'current' symlink
    ln -sfn "$R_PREFIX" "$R_INSTALL_DIR/current"
    print_success "Symlink created: ~/.local/R/current -> $R_VERSION"
}

# Cleanup build files
cleanup() {
    print_info "Cleaning up build directory..."
    rm -rf "$BUILD_DIR"
    print_success "Build files removed"
}

# Main
main() {
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║           R ${R_VERSION} Source Installation                       ║"
    echo "║           Install location: ~/.local/R/${R_VERSION}                ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""

    # Check if already installed
    if [ -x "$R_PREFIX/bin/R" ]; then
        print_success "R ${R_VERSION} is already installed at $R_PREFIX"
        print_info "To reinstall, run: rm -rf $R_PREFIX && $0"
        exit 0
    fi

    check_dependencies
    check_optional_deps
    download_r
    build_r
    install_r
    cleanup

    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                    Installation Complete!                    ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    echo "Add to your PATH (already configured in dotfiles .zshrc):"
    echo "  export PATH=\"\$HOME/.local/R/current/bin:\$PATH\""
    echo ""
    echo "Verify installation:"
    echo "  $R_PREFIX/bin/R --version"
    echo ""
    echo "Install R packages:"
    echo "  $R_PREFIX/bin/R -e 'install.packages(\"languageserver\")'"
    echo ""
}

main "$@"
