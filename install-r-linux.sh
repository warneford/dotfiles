#!/bin/bash

# Install R pre-compiled binary on Linux without root access
# This script installs R to ~/.local/R

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${YELLOW}→${NC} $1"
}

# Detect Linux distribution and architecture
print_info "Detecting system..."
ARCH=$(uname -m)
if [ "$ARCH" != "x86_64" ]; then
    print_error "Only x86_64 architecture is supported by this script"
    exit 1
fi

# Detect distribution
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$ID
    VERSION=$VERSION_ID
else
    print_error "Cannot detect Linux distribution"
    exit 1
fi

print_info "Detected: $DISTRO $VERSION ($ARCH)"

# Set R version
R_VERSION="4.5.1"
R_INSTALL_DIR="$HOME/.local/R/${R_VERSION}"
R_CURRENT_LINK="$HOME/.local/R/current"

# Download pre-compiled R based on distribution
case $DISTRO in
    ubuntu|debian)
        print_info "Downloading R ${R_VERSION} for Ubuntu/Debian..."
        # Use rig (R installation manager) for easy binary install
        if ! command -v rig &> /dev/null; then
            print_info "Installing rig (R installation manager)..."
            curl -Ls https://github.com/r-lib/rig/releases/download/latest/rig-linux-latest.tar.gz | \
                tar xz -C /tmp
            mkdir -p "$HOME/.local/bin"
            mv /tmp/rig "$HOME/.local/bin/"
            export PATH="$HOME/.local/bin:$PATH"
            print_success "rig installed"
        fi

        print_info "Installing R ${R_VERSION} via rig..."
        rig add ${R_VERSION} --without-pak

        # rig installs to ~/.local/share/rig, create our symlink structure
        mkdir -p "$HOME/.local/R"
        ln -sf "$HOME/.local/share/rig/${R_VERSION}" "$R_INSTALL_DIR"
        rm -f "$R_CURRENT_LINK"
        ln -sf "$R_INSTALL_DIR" "$R_CURRENT_LINK"
        ;;

    centos|rhel|fedora)
        print_info "Downloading R ${R_VERSION} tarball..."
        mkdir -p "$HOME/tmp" "$HOME/.local/R"

        # Download generic Linux binary
        curl -L "https://cdn.posit.co/r/centos-7/pkgs/R-${R_VERSION}-1-1.x86_64.rpm" -o "$HOME/tmp/R.rpm"

        # Extract RPM without installing
        cd "$HOME/tmp"
        rpm2cpio R.rpm | cpio -idmv

        # Move to installation directory
        mv "$HOME/tmp/usr/lib64/R" "$R_INSTALL_DIR"

        # Create symlink
        rm -f "$R_CURRENT_LINK"
        ln -sf "$R_INSTALL_DIR" "$R_CURRENT_LINK"

        # Cleanup
        rm -rf "$HOME/tmp/R.rpm" "$HOME/tmp/usr"
        ;;

    *)
        print_error "Unsupported distribution: $DISTRO"
        print_info "Try using conda: conda install -c conda-forge r-base"
        exit 1
        ;;
esac

print_success "R ${R_VERSION} installed to ${R_INSTALL_DIR}"

echo ""
print_success "Installation complete!"
echo ""
echo "Add to your .zshrc:"
echo '  export PATH="$HOME/.local/R/current/bin:$PATH"'
echo ""
echo "Then run:"
echo "  source ~/.zshrc"
echo "  R --version"
echo ""
