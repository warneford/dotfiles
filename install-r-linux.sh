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

# Check if already installed
if [ -d "$R_INSTALL_DIR/bin" ]; then
    print_success "R ${R_VERSION} already installed at ${R_INSTALL_DIR}"
    rm -f "$R_CURRENT_LINK"
    ln -sf "$R_INSTALL_DIR" "$R_CURRENT_LINK"
    print_success "Updated symlink at ${R_CURRENT_LINK}"
    echo ""
    echo "R is ready to use!"
    echo "Run: source ~/.zshrc"
    echo "Then: R --version"
    exit 0
fi

# Download pre-compiled R from Posit Public Package Manager
print_info "Downloading R ${R_VERSION} binary from Posit..."

mkdir -p "$HOME/tmp" "$HOME/.local/R"

case $DISTRO in
    ubuntu|debian)
        # Determine Ubuntu version for correct binary
        UBUNTU_VERSION=$(echo $VERSION_ID | sed 's/\..*//')

        if [ "$UBUNTU_VERSION" = "22" ] || [ "$UBUNTU_VERSION" = "24" ]; then
            BINARY_BASE="ubuntu-${UBUNTU_VERSION}04"
        elif [ "$UBUNTU_VERSION" = "20" ]; then
            BINARY_BASE="ubuntu-2004"
        else
            print_error "Unsupported Ubuntu version: $VERSION_ID"
            print_info "Try using conda: conda install -c conda-forge r-base"
            exit 1
        fi

        DOWNLOAD_URL="https://cdn.posit.co/r/${BINARY_BASE}/pkgs/r-${R_VERSION}_1_amd64.deb"
        print_info "Downloading from: ${DOWNLOAD_URL}"

        curl -L "${DOWNLOAD_URL}" -o "$HOME/tmp/R.deb"

        # Extract DEB without installing
        cd "$HOME/tmp"
        ar x R.deb
        tar -xzf data.tar.gz

        # Move to installation directory (remove if exists)
        rm -rf "$R_INSTALL_DIR"
        mv "$HOME/tmp/opt/R/${R_VERSION}" "$R_INSTALL_DIR"

        # Cleanup
        rm -rf "$HOME/tmp/R.deb" "$HOME/tmp/control.tar.gz" "$HOME/tmp/data.tar.gz" "$HOME/tmp/debian-binary" "$HOME/tmp/opt"
        ;;

    centos|rhel|fedora)
        print_info "Downloading R ${R_VERSION} for RHEL/CentOS..."

        DOWNLOAD_URL="https://cdn.posit.co/r/centos-7/pkgs/R-${R_VERSION}-1-1.x86_64.rpm"
        curl -L "${DOWNLOAD_URL}" -o "$HOME/tmp/R.rpm"

        # Extract RPM without installing
        cd "$HOME/tmp"
        rpm2cpio R.rpm | cpio -idmv

        # Move to installation directory (remove if exists)
        rm -rf "$R_INSTALL_DIR"
        mv "$HOME/tmp/opt/R/${R_VERSION}" "$R_INSTALL_DIR"

        # Cleanup
        rm -rf "$HOME/tmp/R.rpm" "$HOME/tmp/opt"
        ;;

    *)
        print_error "Unsupported distribution: $DISTRO"
        print_info "Try using conda: conda install -c conda-forge r-base"
        exit 1
        ;;
esac

# Create symlink
rm -f "$R_CURRENT_LINK"
ln -sf "$R_INSTALL_DIR" "$R_CURRENT_LINK"

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
