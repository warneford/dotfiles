#!/bin/bash

set -e

echo "🚀 Starting dotfiles installation..."

# Detect OS and SSH session
OS="$(uname -s)"
IS_MAC=false
IS_LINUX=false
IS_SSH=false

case "$OS" in
    Darwin*) IS_MAC=true ;;
    Linux*)  IS_LINUX=true ;;
esac

if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    IS_SSH=true
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${YELLOW}→${NC} $1"
}

# Get the directory where the script is located
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# macOS: Install dependencies via Homebrew
if $IS_MAC; then
    if ! command -v brew &> /dev/null; then
        print_error "Homebrew not found. Please install Homebrew first:"
        echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        exit 1
    fi

    print_info "Installing dependencies via Homebrew..."

    # Install required dependencies for LSP servers and nvim plugins
    DEPENDENCIES=(
        "node"          # Required for pyright and ts_ls (JavaScript/TypeScript LSP)
        "python"        # Python and pip
        "ripgrep"       # Required for Telescope fuzzy finder
        "neovim"        # Neovim editor
        "air"           # R code formatter (Posit/tidyverse)
        "lazygit"       # Git TUI for nvim
        "tmux"          # Terminal multiplexer
    )
    # Note: We use CRAN R (not Homebrew R) for better package compatibility
    # Download from: https://cloud.r-project.org/bin/macosx/

    for dep in "${DEPENDENCIES[@]}"; do
        if brew list "$dep" &> /dev/null; then
            print_success "$dep already installed"
        else
            print_info "Installing $dep..."
            brew install "$dep"
            print_success "$dep installed"
        fi
    done
else
    # Linux: Install all dependencies without root access (batteries included!)
    print_info "Linux detected - setting up dependencies (no root required)..."

    # Install Rust (required for bob-nvim and ripgrep) if not already installed
    if ! command -v cargo &> /dev/null; then
        print_info "Installing Rust..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "$HOME/.cargo/env"
        print_success "Rust installed"
    else
        print_success "Rust already installed"
    fi

    # Source cargo env to ensure cargo is available
    export PATH="$HOME/.cargo/bin:$PATH"

    # Install ripgrep via cargo (no root needed)
    if ! command -v rg &> /dev/null; then
        print_info "Installing ripgrep..."
        cargo install ripgrep
        print_success "ripgrep installed"
    else
        print_success "ripgrep already installed"
    fi

    # Install nvm (Node Version Manager) if not already installed
    # Check both common nvm installation locations
    if [ ! -d "$HOME/.nvm" ] && [ ! -d "$HOME/.config/nvm" ]; then
        print_info "Installing nvm (Node Version Manager)..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
        print_success "nvm installed"
    else
        print_success "nvm already installed"
    fi

    # Load nvm from whichever location it's installed
    if [ -d "$HOME/.config/nvm" ]; then
        export NVM_DIR="$HOME/.config/nvm"
    else
        export NVM_DIR="$HOME/.nvm"
    fi
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

    # Install Node.js LTS via nvm (includes npm)
    if ! command -v node &> /dev/null; then
        print_info "Installing Node.js LTS via nvm..."
        nvm install --lts
        nvm use --lts
        print_success "Node.js and npm installed"
    else
        print_success "Node.js already installed ($(node --version))"
    fi

    # Install bob-nvim (neovim version manager)
    if ! command -v bob &> /dev/null; then
        print_info "Installing bob-nvim (neovim version manager)..."
        cargo install bob-nvim
        print_success "bob-nvim installed"

        # Add bob's nvim to PATH
        export PATH="$HOME/.local/share/bob/nvim-bin:$PATH"

        # Install latest stable neovim
        print_info "Installing neovim stable via bob..."
        bob install stable
        bob use stable
        print_success "Neovim installed via bob"
    else
        print_success "bob-nvim already installed"
        # Ensure we're using stable
        bob use stable 2>/dev/null || true
    fi

    # Check for Python3
    if command -v python3 &> /dev/null; then
        print_success "Python3 found ($(python3 --version))"
    else
        print_info "Python3 not found - please install manually or use your package manager"
    fi

    # Install lazygit (Git TUI)
    if ! command -v lazygit &> /dev/null; then
        print_info "Installing lazygit..."
        LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
        curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
        tar xf /tmp/lazygit.tar.gz -C /tmp lazygit
        install /tmp/lazygit "$HOME/.local/bin"
        rm /tmp/lazygit.tar.gz /tmp/lazygit
        print_success "lazygit installed"
    else
        print_success "lazygit already installed ($(lazygit --version | head -1))"
    fi

    # Install R if not already present
    if ! command -v R &> /dev/null && [ ! -d "$HOME/.local/R/current/bin" ]; then
        print_info "R not found - installing R 4.5.1..."
        if [ -f "$DOTFILES_DIR/install-r-linux.sh" ]; then
            bash "$DOTFILES_DIR/install-r-linux.sh"
            # Add R to PATH for the remainder of this script
            export PATH="$HOME/.local/R/current/bin:$PATH"
            export R_HOME="$HOME/.local/R/current/lib/R"
        else
            print_info "R installation options for Linux without root:"
            echo "  1. Run: ./install-r-linux.sh (in dotfiles directory)"
            echo "  2. Use conda: conda install -c conda-forge r-base"
        fi
    else
        print_success "R already installed"
        # Ensure R is in PATH for this script
        if [ -d "$HOME/.local/R/current/bin" ]; then
            export PATH="$HOME/.local/R/current/bin:$PATH"
            export R_HOME="$HOME/.local/R/current/lib/R"
        fi
    fi

    print_info "Continuing with configuration setup..."
fi

# Install oh-my-zsh if not already installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    print_info "Installing oh-my-zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    print_success "oh-my-zsh installed"
else
    print_success "oh-my-zsh already installed"
fi

# Install Powerlevel10k theme
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
    print_info "Installing Powerlevel10k theme..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    print_success "Powerlevel10k installed"
else
    print_success "Powerlevel10k already installed"
fi

# Install zsh-autosuggestions
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
    print_info "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    print_success "zsh-autosuggestions installed"
else
    print_success "zsh-autosuggestions already installed"
fi

# Install zsh-syntax-highlighting
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
    print_info "Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    print_success "zsh-syntax-highlighting installed"
else
    print_success "zsh-syntax-highlighting already installed"
fi

# Backup existing configs
print_info "Backing up existing configurations..."
if [ -f "$HOME/.zshrc" ]; then
    cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
    print_success "Backed up .zshrc"
fi

if [ -d "$HOME/.config/nvim" ]; then
    mv "$HOME/.config/nvim" "$HOME/.config/nvim.backup.$(date +%Y%m%d_%H%M%S)"
    print_success "Backed up nvim config"
fi

# Create symlinks
print_info "Creating symlinks..."

# Symlink .zshrc
ln -sf "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
print_success "Linked .zshrc"

# Symlink nvim config
mkdir -p "$HOME/.config"
ln -sf "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
print_success "Linked nvim config"

# Symlink tmux config
ln -sf "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"
print_success "Linked tmux config"

# Symlink aliases
ln -sf "$DOTFILES_DIR/zsh/aliases.zsh" "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/aliases.zsh"
print_success "Linked aliases"

# Setup Ghostty config (only on local machines, not SSH sessions)
if ! $IS_SSH; then
    if command -v ghostty &> /dev/null || [ -d "/Applications/Ghostty.app" ]; then
        print_info "Setting up Ghostty configuration..."

        # Remove Application Support config if it exists (to avoid conflicts)
        if [ -d "$HOME/Library/Application Support/com.mitchellh.ghostty" ]; then
            rm -f "$HOME/Library/Application Support/com.mitchellh.ghostty/config"*
            print_info "Removed Application Support config (using ~/.config/ghostty instead)"
        fi

        # Backup existing ghostty config if it exists and is not a symlink
        if [ -e "$HOME/.config/ghostty" ] && [ ! -L "$HOME/.config/ghostty" ]; then
            mv "$HOME/.config/ghostty" "$HOME/.config/ghostty.backup.$(date +%Y%m%d_%H%M%S)"
            print_success "Backed up existing ghostty config"
        fi

        # Remove existing symlink if present, then create new one
        rm -rf "$HOME/.config/ghostty"
        ln -sf "$DOTFILES_DIR/ghostty" "$HOME/.config/ghostty"
        print_success "Linked Ghostty directory to ~/.config/ghostty"
    else
        print_info "Ghostty not found - skipping Ghostty configuration"
        if $IS_MAC; then
            print_info "Install with: brew install --cask ghostty"
        fi
    fi
else
    print_info "SSH session detected - skipping Ghostty configuration (terminal emulator not needed)"
fi

echo ""
print_success "Installation complete!"
echo ""

# Install Quarto
print_info "Installing Quarto CLI..."
if ! command -v quarto &> /dev/null; then
    if $IS_MAC; then
        brew install --cask quarto
        print_success "Quarto CLI installed"
    else
        # Linux: Install to ~/.local/quarto (no root required)
        print_info "Fetching latest Quarto version..."
        QUARTO_VERSION=$(curl -s https://api.github.com/repos/quarto-dev/quarto-cli/releases/latest | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')

        if [ -z "$QUARTO_VERSION" ]; then
            print_error "Failed to fetch latest Quarto version"
            print_info "Manual installation: https://quarto.org/docs/get-started/"
        else
            QUARTO_URL="https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-amd64.tar.gz"

            print_info "Downloading Quarto ${QUARTO_VERSION}..."
            mkdir -p ~/.local
            curl -L "$QUARTO_URL" -o /tmp/quarto.tar.gz
            tar -xzf /tmp/quarto.tar.gz -C ~/.local
            mv ~/.local/quarto-${QUARTO_VERSION} ~/.local/quarto
            rm /tmp/quarto.tar.gz

            # Add to PATH
            export PATH="$HOME/.local/quarto/bin:$PATH"
            print_success "Quarto CLI ${QUARTO_VERSION} installed to ~/.local/quarto"
        fi
    fi
else
    print_success "Quarto CLI already installed"
fi

# Install Python packages for image.nvim
print_info "Installing Python packages for image.nvim..."
python3 -m pip install --user pynvim cairosvg pillow
print_success "Python packages installed"

# Install R packages for nvim-r (if R is available)
if command -v Rscript &> /dev/null; then
    print_info "Installing R packages for nvim-r..."
    Rscript -e 'if (!require("languageserver")) install.packages("languageserver", repos="https://cloud.r-project.org")'
    print_success "R languageserver package installed"
else
    print_info "R not found - skipping R package installation"
    print_info "After installing R, run: Rscript -e 'install.packages(\"languageserver\")'"
fi

# Install pipx (portable Python CLI tool installer - works on macOS and Linux)
print_info "Installing pipx..."
if ! command -v pipx &> /dev/null; then
    python3 -m pip install --user pipx
    python3 -m pipx ensurepath
    export PATH="$PATH:$HOME/.local/bin"
    print_success "pipx installed"
else
    print_success "pipx already installed"
fi

# Install radian (enhanced R console with RStudio-like features)
print_info "Installing radian via pipx..."
if pipx list 2>/dev/null | grep -q "radian"; then
    print_success "radian already installed"
else
    pipx install radian
    print_success "radian installed"
fi

echo ""
print_success "Installation complete!"
echo ""
print_info "Next steps:"
echo "  1. Restart your terminal or run: source ~/.zshrc"
echo "  2. Run 'p10k configure' to configure your Powerlevel10k theme"
echo "  3. Open nvim - lazy.nvim will auto-install and plugins will be loaded"
if command -v radian &> /dev/null; then
    echo "  4. Start tmux, open R file in nvim, run 'radian' in right pane"
    echo "     Send code with <C-c><C-c> or <leader>ca to auto-configure vim-slime"
else
    echo "  4. Install R and radian, then restart this script for R packages"
fi
if command -v quarto &> /dev/null; then
    echo "  5. In a Quarto file (.qmd), press ,qp to preview"
else
    echo "  5. Install Quarto (see instructions above) for .qmd file support"
fi
if ! $IS_SSH && (command -v ghostty &> /dev/null || [ -d "/Applications/Ghostty.app" ]); then
    echo "  6. Restart Ghostty to load the configuration"
fi
echo ""
print_info "Included nvim plugins:"
echo "  - Harpoon2 (file navigation)"
echo "  - Leap.nvim (motion plugin)"
echo "  - Telescope (fuzzy finder)"
echo "  - LSP (language servers)"
echo "  - Treesitter (syntax highlighting)"
echo "  - Fugitive (git integration)"
echo "  - Undotree (undo history)"
echo "  - Trouble (diagnostics)"
echo "  - And more from ThePrimeagen's config!"
echo ""
