#!/bin/bash

set -e

echo "🚀 Starting dotfiles installation..."

# Detect OS, SSH session, and container environment
OS="$(uname -s)"
IS_MAC=false
IS_LINUX=false
IS_SSH=false
IS_CONTAINER=false

case "$OS" in
    Darwin*) IS_MAC=true ;;
    Linux*)  IS_LINUX=true ;;
esac

if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    IS_SSH=true
fi

if [ -f "/.dockerenv" ]; then
    IS_CONTAINER=true
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
        "uv"            # Fast Python package/environment manager
        "direnv"        # Directory-based environment management
        "fzf"           # Fuzzy finder for shell
        "stow"          # Symlink farm manager for dotfiles
        "fd"            # Fast file finder for Telescope
        "prettier"      # Code formatter for JS/TS/JSON/etc
        "stylua"        # Lua code formatter
        "pngpaste"      # Paste images from clipboard (for img-clip.nvim)
        "fortune"       # Random quotes for nvim dashboard
        "imagemagick"   # Image conversion for snacks.nvim image viewer
    )

    # macOS GUI apps (casks)
    CASK_DEPENDENCIES=(
        "karabiner-elements"  # Keyboard customization
    )

    # macOS tools from custom taps
    TAP_DEPENDENCIES=(
        "FelixKratz/formulae/borders"  # JankyBorders - window border highlights
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

    # Install cask dependencies (GUI apps)
    for cask in "${CASK_DEPENDENCIES[@]}"; do
        if brew list --cask "$cask" &> /dev/null; then
            print_success "$cask already installed"
        else
            print_info "Installing $cask..."
            brew install --cask "$cask"
            print_success "$cask installed"
        fi
    done

    # Install tap dependencies (tools from custom taps)
    for tap_dep in "${TAP_DEPENDENCIES[@]}"; do
        dep_name=$(basename "$tap_dep")
        if brew list "$dep_name" &> /dev/null; then
            print_success "$dep_name already installed"
        else
            print_info "Installing $tap_dep..."
            brew install "$tap_dep"
            print_success "$dep_name installed"
        fi
    done

    # Start Karabiner-Elements on login (it manages its own login item)
    if [ -d "/Applications/Karabiner-Elements.app" ]; then
        open -a "Karabiner-Elements"
        print_success "Karabiner-Elements started (will auto-start on login)"
    fi
else
    # Linux: Install all dependencies without root access (batteries included!)
    print_info "Linux detected - setting up dependencies (no root required)..."

    # In containers, most tools are pre-installed via Dockerfile - skip version managers
    if $IS_CONTAINER; then
        print_info "Container detected - skipping version manager installs (using system packages)"

        # Just verify tools exist
        command -v rg &> /dev/null && print_success "ripgrep available" || print_info "ripgrep not found"
        command -v node &> /dev/null && print_success "Node.js available ($(node --version))" || print_info "Node.js not found"
        command -v nvim &> /dev/null && print_success "Neovim available ($(nvim --version | head -1))" || print_info "Neovim not found"
    else
        # Host Linux: Install tools via version managers (no root required)

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

        # Ensure a default toolchain is set (fixes "no default is configured" error)
        if command -v rustup &> /dev/null && ! rustup default &> /dev/null; then
            print_info "Setting default Rust toolchain..."
            rustup default stable
            print_success "Rust default toolchain set"
        fi

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

    # Install uv (fast Python package/environment manager)
    if ! command -v uv &> /dev/null; then
        print_info "Installing uv..."
        curl -LsSf https://astral.sh/uv/install.sh | sh
        # Add to PATH for current session
        export PATH="$HOME/.local/bin:$PATH"
        print_success "uv installed"
    else
        print_success "uv already installed ($(uv --version))"
    fi

    # Install direnv (directory-based environment management)
    if ! command -v direnv &> /dev/null; then
        print_info "Installing direnv..."
        curl -sfL https://direnv.net/install.sh | bash
        print_success "direnv installed"
    else
        print_success "direnv already installed ($(direnv --version))"
    fi

    # Install GNU Stow (symlink farm manager for dotfiles)
    if ! command -v stow &> /dev/null; then
        print_info "Installing GNU Stow..."
        STOW_VERSION="2.4.0"
        curl -L "https://ftp.gnu.org/gnu/stow/stow-${STOW_VERSION}.tar.gz" -o /tmp/stow.tar.gz
        tar -xzf /tmp/stow.tar.gz -C /tmp
        cd /tmp/stow-${STOW_VERSION}
        ./configure --prefix="$HOME/.local"
        make install
        cd "$DOTFILES_DIR"
        rm -rf /tmp/stow*
        print_success "GNU Stow installed"
    else
        print_success "GNU Stow already installed"
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
            echo "  Run: ./install-r-linux.sh (builds R from source)"
        fi
    else
        print_success "R already installed"
        # Ensure R is in PATH for this script
        if [ -d "$HOME/.local/R/current/bin" ]; then
            export PATH="$HOME/.local/R/current/bin:$PATH"
            export R_HOME="$HOME/.local/R/current/lib/R"
        fi
    fi

    # Install terminfo files for tmux (true color support)
    if [ ! -f "$HOME/.terminfo/t/tmux-256color" ]; then
        print_info "Installing tmux-256color terminfo..."
        mkdir -p "$HOME/.terminfo"
        cat > /tmp/tmux-256color.ti << 'EOF'
tmux-256color|tmux with 256 colors,
	use=screen-256color, Tc,
EOF
        tic -x -o "$HOME/.terminfo" /tmp/tmux-256color.ti
        rm /tmp/tmux-256color.ti
        print_success "tmux-256color terminfo installed"
    else
        print_success "tmux-256color terminfo already installed"
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

# Install tmux-window-name plugin (no TPM needed)
TMUX_PLUGINS_DIR="$HOME/.tmux/plugins"
if [ ! -d "$TMUX_PLUGINS_DIR/tmux-window-name" ]; then
    print_info "Installing tmux-window-name..."
    mkdir -p "$TMUX_PLUGINS_DIR"
    git clone https://github.com/ofirgall/tmux-window-name.git "$TMUX_PLUGINS_DIR/tmux-window-name"
    print_success "tmux-window-name installed"
else
    print_success "tmux-window-name already installed"
fi

# Install libtmux for tmux-window-name (in dedicated venv)
TMUX_PYTHON_ENV="$HOME/.local/share/tmux/python-env"
print_info "Setting up Python environment for tmux plugins..."
if [ ! -d "$TMUX_PYTHON_ENV" ]; then
    if command -v uv &> /dev/null; then
        uv venv "$TMUX_PYTHON_ENV"
    else
        python3 -m venv "$TMUX_PYTHON_ENV"
    fi
    print_success "Created tmux Python venv"
fi
if command -v uv &> /dev/null; then
    uv pip install --python "$TMUX_PYTHON_ENV/bin/python" libtmux
else
    "$TMUX_PYTHON_ENV/bin/pip" install libtmux
fi
print_success "libtmux installed to tmux venv"

# Backup existing configs that stow would conflict with
print_info "Backing up existing configurations..."
backup_if_exists() {
    local target="$1"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        mv "$target" "${target}.backup.$(date +%Y%m%d_%H%M%S)"
        print_success "Backed up $(basename "$target")"
    elif [ -L "$target" ]; then
        rm "$target"  # Remove old symlinks so stow can recreate them
    fi
}

mkdir -p "$HOME/.config"
backup_if_exists "$HOME/.zshrc"
backup_if_exists "$HOME/.p10k.zsh"
backup_if_exists "$HOME/.tmux.conf"
backup_if_exists "$HOME/.Rprofile"
backup_if_exists "$HOME/.config/nvim"
backup_if_exists "$HOME/.config/direnv"
backup_if_exists "$HOME/.config/radian"

# Stow packages
print_info "Stowing dotfiles..."

# Helper function to stow a package
stow_package() {
    local pkg="$1"
    if [ -d "$DOTFILES_DIR/$pkg" ]; then
        stow -d "$DOTFILES_DIR" -t "$HOME" --restow "$pkg" 2>/dev/null && \
            print_success "Stowed $pkg" || \
            print_error "Failed to stow $pkg"
    fi
}

# Container mode: copy .zshrc instead of stowing (so nvm etc can modify it)
if $IS_CONTAINER; then
    cp "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
    [ -f "$DOTFILES_DIR/zsh/.p10k.zsh" ] && cp "$DOTFILES_DIR/zsh/.p10k.zsh" "$HOME/.p10k.zsh"
    print_success "Copied zsh configs (container mode - editable)"
else
    stow_package "zsh"
fi

# Core packages (always stow these)
stow_package "tmux"
stow_package "R"
stow_package "nvim"
stow_package "direnv"
stow_package "radian"
stow_package "bin"
stow_package "terminfo"

# Remove old .radian_profile if it exists and isn't a symlink
if [ -f "$HOME/.radian_profile" ] && [ ! -L "$HOME/.radian_profile" ]; then
    rm "$HOME/.radian_profile"
    print_info "Removed old ~/.radian_profile (now using ~/.config/radian/profile)"
fi

# oh-my-zsh custom plugins (can't use stow - dynamic path)
ln -sf "$DOTFILES_DIR/zsh/aliases.zsh" "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/aliases.zsh"
print_success "Linked aliases"
ln -sf "$DOTFILES_DIR/zsh/functions.zsh" "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/functions.zsh"
print_success "Linked functions"

# Git config include (not a symlink - uses git's include mechanism)
if [ -f "$DOTFILES_DIR/git/config" ]; then
    INCLUDE_PATH="$DOTFILES_DIR/git/config"
    if ! grep -q "path = $INCLUDE_PATH" "$HOME/.gitconfig" 2>/dev/null; then
        git config --global include.path "$INCLUDE_PATH"
        print_success "Added git config include"
    else
        print_success "Git config include already present"
    fi
fi

# Setup Ghostty config (only on local machines, not SSH sessions)
if ! $IS_SSH; then
    if command -v ghostty &> /dev/null || [ -d "/Applications/Ghostty.app" ]; then
        print_info "Setting up Ghostty configuration..."

        # Remove Application Support config if it exists (to avoid conflicts)
        if [ -d "$HOME/Library/Application Support/com.mitchellh.ghostty" ]; then
            rm -f "$HOME/Library/Application Support/com.mitchellh.ghostty/config"*
            print_info "Removed Application Support config (using ~/.config/ghostty instead)"
        fi

        backup_if_exists "$HOME/.config/ghostty"
        stow_package "ghostty"
    else
        print_info "Ghostty not found - skipping Ghostty configuration"
        if $IS_MAC; then
            print_info "Install with: brew install --cask ghostty"
        fi
    fi
else
    print_info "SSH session detected - skipping Ghostty configuration (terminal emulator not needed)"
fi

# Setup macOS GUI apps (only on macOS, not in SSH sessions)
if $IS_MAC && ! $IS_SSH; then
    # AeroSpace tiling window manager
    if command -v aerospace &> /dev/null || [ -d "/Applications/AeroSpace.app" ]; then
        backup_if_exists "$HOME/.config/aerospace"
        stow_package "aerospace"
    else
        print_info "AeroSpace not found - skipping AeroSpace configuration"
        print_info "Install with: brew install --cask nikitabobko/tap/aerospace"
    fi

    # Karabiner-Elements (keyboard customization)
    if [ -d "/Applications/Karabiner-Elements.app" ]; then
        backup_if_exists "$HOME/.config/karabiner"
        stow_package "karabiner"
    else
        print_info "Karabiner-Elements not found - skipping Karabiner configuration"
        print_info "Install with: brew install --cask karabiner-elements"
    fi

    # SketchyBar (status bar for aerospace workspaces)
    if command -v sketchybar &> /dev/null; then
        backup_if_exists "$HOME/.config/sketchybar"
        stow_package "sketchybar"
        brew services restart sketchybar 2>/dev/null || true
    else
        print_info "SketchyBar not found - skipping SketchyBar configuration"
        print_info "Install with: brew tap FelixKratz/formulae && brew install sketchybar"
    fi

    # JankyBorders (window border highlights)
    if command -v borders &> /dev/null; then
        backup_if_exists "$HOME/.config/borders"
        stow_package "borders"
        brew services restart borders 2>/dev/null || true
        print_success "JankyBorders service started"
    else
        print_info "JankyBorders not found - skipping borders configuration"
        print_info "Install with: brew install FelixKratz/formulae/borders"
    fi
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

# Install Python packages for neovim plugins (image.nvim, etc.)
# Use a dedicated venv to avoid conflicts with project venvs
NVIM_PYTHON_ENV="$HOME/.local/share/nvim/python-env"
print_info "Setting up Python environment for neovim..."
if [ ! -d "$NVIM_PYTHON_ENV" ]; then
    uv venv "$NVIM_PYTHON_ENV"
    print_success "Created neovim Python venv"
fi
uv pip install --python "$NVIM_PYTHON_ENV/bin/python" pynvim cairosvg pillow
print_success "Python packages installed to nvim venv"

# Install R packages for nvim-r (if R is available)
if command -v Rscript &> /dev/null; then
    print_info "Installing R packages for nvim-r..."
    Rscript -e 'if (!require("languageserver")) install.packages("languageserver", repos="https://cloud.r-project.org")'
    print_success "R languageserver package installed"
else
    print_info "R not found - skipping R package installation"
    print_info "After installing R, run: Rscript -e 'install.packages(\"languageserver\")'"
fi

# Install Mason packages for neovim (LSP servers, formatters, etc.)
if command -v nvim &> /dev/null; then
    print_info "Installing Mason packages (air formatter)..."
    nvim --headless "+MasonInstall air" "+qa"
    print_success "Mason packages installed"
fi

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
