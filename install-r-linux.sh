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

# Check if conda is installed
if ! command -v conda &> /dev/null; then
    print_error "conda not found - please install miniconda or anaconda first"
    echo ""
    echo "To install miniconda:"
    echo "  curl -O https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"
    echo "  bash Miniconda3-latest-Linux-x86_64.sh"
    echo ""
    exit 1
fi

print_success "conda found ($(conda --version))"

# Check if R environment already exists
if conda env list | grep -q "^${CONDA_ENV_NAME} "; then
    print_success "R conda environment already exists"
    print_info "To reinstall, run: conda env remove -n ${CONDA_ENV_NAME}"
    exit 0
fi

# Create conda environment with R
print_info "Creating conda environment '${CONDA_ENV_NAME}' with R ${R_VERSION}..."
conda create -n "${CONDA_ENV_NAME}" -c conda-forge -y \
    r-base=${R_VERSION} \
    r-languageserver \
    r-jsonlite \
    r-rlang

print_success "R ${R_VERSION} installed via conda"

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
