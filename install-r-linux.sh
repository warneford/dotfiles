#!/bin/bash

# Install R via conda on Linux without root access
# This script installs R using conda-forge

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

# Set R version
R_VERSION="4.5.1"
CONDA_ENV_NAME="r-base"

# Install miniforge (includes mamba) if conda/mamba not present
if ! command -v mamba &> /dev/null && ! command -v conda &> /dev/null; then
    print_info "conda/mamba not found - installing miniforge (conda + mamba)..."

    MINIFORGE_INSTALLER="$HOME/tmp/Miniforge3-Linux-x86_64.sh"
    mkdir -p "$HOME/tmp"

    # Download miniforge installer (includes mamba and uses conda-forge by default)
    curl -L https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh -o "$MINIFORGE_INSTALLER"

    # Install miniforge to ~/.local/miniforge3
    bash "$MINIFORGE_INSTALLER" -b -p "$HOME/.local/miniforge3"

    # Initialize conda/mamba
    "$HOME/.local/miniforge3/bin/conda" init zsh bash
    "$HOME/.local/miniforge3/bin/mamba" init zsh bash

    # Add to current PATH
    export PATH="$HOME/.local/miniforge3/bin:$PATH"

    # Cleanup installer
    rm -f "$MINIFORGE_INSTALLER"

    print_success "miniforge installed to ~/.local/miniforge3"
    print_info "Mamba and conda have been initialized. You may need to restart your shell."
else
    if command -v mamba &> /dev/null; then
        print_success "mamba found ($(mamba --version | head -1))"
        CONDA_CMD="mamba"
    else
        print_success "conda found ($(conda --version))"
        CONDA_CMD="conda"
    fi
fi

# Use mamba if available, otherwise conda
if command -v mamba &> /dev/null; then
    CONDA_CMD="mamba"
else
    CONDA_CMD="conda"
fi

# Check if R environment already exists
if ${CONDA_CMD} env list | grep -q "^${CONDA_ENV_NAME} "; then
    print_success "R ${CONDA_CMD} environment already exists"
    print_info "To reinstall, run: ${CONDA_CMD} env remove -n ${CONDA_ENV_NAME}"
    exit 0
fi

# Create environment with R using mamba (faster) or conda
print_info "Creating ${CONDA_CMD} environment '${CONDA_ENV_NAME}' with R ${R_VERSION}..."
${CONDA_CMD} create -n "${CONDA_ENV_NAME}" -c conda-forge --override-channels -y \
    r-base=${R_VERSION} \
    r-languageserver \
    r-jsonlite \
    r-rlang

print_success "R ${R_VERSION} installed via ${CONDA_CMD}"

echo ""
print_success "Installation complete!"
echo ""
echo "To use R, activate the conda environment:"
echo "  conda activate ${CONDA_ENV_NAME}"
echo ""
echo "Then run:"
echo "  R --version"
echo "  Rscript -e 'print(\"hello\")'"
echo ""
echo "To make this the default R, add to your .zshrc:"
echo "  conda activate ${CONDA_ENV_NAME}"
echo ""
