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
        "pnpm"          # Fast npm package manager (for sketchybar-app-font)
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
        "carapace"      # Multi-shell completion engine with rich descriptions
        "tree-sitter-cli"  # Required for nvim-treesitter to compile parsers
        "btop"          # System resource monitor
        "ghostscript"   # PDF rendering for snacks.nvim image viewer
        "tectonic"      # LaTeX rendering for snacks.nvim (lightweight TeX)
    )

    # macOS GUI apps (casks)
    CASK_DEPENDENCIES=(
        "karabiner-elements"  # Keyboard customization
        "nikitabobko/tap/aerospace"  # Tiling window manager
        "font-fira-code-nerd-font"  # Nerd Font for terminal/SketchyBar icons
    )

    # macOS tools from custom taps
    TAP_DEPENDENCIES=(
        "FelixKratz/formulae/borders"  # JankyBorders - window border highlights
        "FelixKratz/formulae/sketchybar"  # Status bar for aerospace workspaces
    )
    # Note: We use CRAN R (not Homebrew R) for better package compatibility
    # CRAN R will be installed separately below (not via Homebrew)

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

    # Install pnpm global packages (for snacks.nvim features)
    if command -v pnpm &> /dev/null; then
        if ! command -v mmdc &> /dev/null; then
            print_info "Installing mermaid-cli (for snacks.nvim diagram rendering)..."
            pnpm add -g @mermaid-js/mermaid-cli
            print_success "mermaid-cli installed"
        else
            print_success "mermaid-cli already installed"
        fi
    fi

    # Start Karabiner-Elements on login (it manages its own login item)
    if [ -d "/Applications/Karabiner-Elements.app" ]; then
        open -a "Karabiner-Elements"
        print_success "Karabiner-Elements started (will auto-start on login)"
    fi

    # Install CRAN R (official R build for macOS)
    if ! command -v R &> /dev/null || ! [ -d "/Library/Frameworks/R.framework" ]; then
        print_info "Installing R from CRAN..."

        # Fetch latest R version for macOS ARM64
        R_VERSION=$(curl -s https://cloud.r-project.org/bin/macosx/ | grep -o 'R-[0-9.]*-arm64.pkg' | head -1 | sed 's/R-\(.*\)-arm64.pkg/\1/')

        if [ -z "$R_VERSION" ]; then
            print_error "Failed to fetch R version"
            print_info "Please manually install R from: https://cloud.r-project.org/bin/macosx/"
        else
            R_PKG_URL="https://cloud.r-project.org/bin/macosx/big-sur-arm64/base/R-${R_VERSION}-arm64.pkg"
            print_info "Downloading R ${R_VERSION} for ARM64..."

            curl -L "$R_PKG_URL" -o /tmp/R-installer.pkg

            print_info "Installing R ${R_VERSION} (requires password)..."
            sudo installer -pkg /tmp/R-installer.pkg -target /
            rm /tmp/R-installer.pkg

            print_success "R ${R_VERSION} installed from CRAN"
        fi
    else
        # Check if it's CRAN R (not Homebrew R)
        if [ -d "/Library/Frameworks/R.framework" ]; then
            R_VERSION=$(R --version | head -1 | awk '{print $3}')
            print_success "CRAN R already installed (version ${R_VERSION})"
        else
            print_error "R is installed but not from CRAN"
            print_info "Please manually install CRAN R from: https://cloud.r-project.org/bin/macosx/"
        fi
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

        # Install tree-sitter CLI (required for nvim-treesitter to compile parsers)
        if ! command -v tree-sitter &> /dev/null; then
            print_info "Installing tree-sitter CLI..."
            TS_VERSION=$(curl -sI https://github.com/tree-sitter/tree-sitter/releases/latest | grep -i "^location:" | sed -E 's|.*/v([0-9.]+).*|\1|')
            curl -Lo /tmp/tree-sitter.gz "https://github.com/tree-sitter/tree-sitter/releases/download/v${TS_VERSION}/tree-sitter-linux-x64.gz"
            gunzip /tmp/tree-sitter.gz
            install /tmp/tree-sitter "$HOME/.local/bin"
            rm /tmp/tree-sitter
            print_success "tree-sitter CLI installed"
        else
            print_success "tree-sitter CLI already installed"
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

    # Install carapace (multi-shell completion engine)
    if ! command -v carapace &> /dev/null; then
        print_info "Installing carapace..."
        CARAPACE_VERSION=$(curl -s https://api.github.com/repos/carapace-sh/carapace-bin/releases/latest | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')
        curl -Lo /tmp/carapace.tar.gz "https://github.com/carapace-sh/carapace-bin/releases/download/v${CARAPACE_VERSION}/carapace-bin_${CARAPACE_VERSION}_linux_amd64.tar.gz"
        tar xf /tmp/carapace.tar.gz -C /tmp carapace
        install /tmp/carapace "$HOME/.local/bin"
        rm /tmp/carapace.tar.gz /tmp/carapace
        print_success "carapace installed"
    else
        print_success "carapace already installed ($(carapace --version))"
    fi

    # Install fzf (fuzzy finder - required for fzf-lua nvim plugin)
    if ! command -v fzf &> /dev/null; then
        print_info "Installing fzf..."
        FZF_VERSION=$(curl -s https://api.github.com/repos/junegunn/fzf/releases/latest | grep '"tag_name"' | sed -E 's/.*"v?([^"]+)".*/\1/')
        curl -Lo /tmp/fzf.tar.gz "https://github.com/junegunn/fzf/releases/download/v${FZF_VERSION}/fzf-${FZF_VERSION}-linux_amd64.tar.gz"
        tar xf /tmp/fzf.tar.gz -C /tmp fzf
        install /tmp/fzf "$HOME/.local/bin"
        rm /tmp/fzf.tar.gz /tmp/fzf
        print_success "fzf installed"
    else
        print_success "fzf already installed ($(fzf --version | head -1))"
    fi

    # Install fd (fast file finder - required for fzf-lua file search)
    if ! command -v fd &> /dev/null; then
        print_info "Installing fd..."
        FD_VERSION=$(curl -s https://api.github.com/repos/sharkdp/fd/releases/latest | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')
        curl -Lo /tmp/fd.tar.gz "https://github.com/sharkdp/fd/releases/download/v${FD_VERSION}/fd-v${FD_VERSION}-x86_64-unknown-linux-gnu.tar.gz"
        tar xf /tmp/fd.tar.gz -C /tmp
        install /tmp/fd-v${FD_VERSION}-x86_64-unknown-linux-gnu/fd "$HOME/.local/bin"
        rm -rf /tmp/fd.tar.gz /tmp/fd-v${FD_VERSION}-x86_64-unknown-linux-gnu
        print_success "fd installed"
    else
        print_success "fd already installed ($(fd --version))"
    fi

    # Install btop (system resource monitor)
    if ! command -v btop &> /dev/null; then
        print_info "Installing btop..."
        BTOP_VERSION=$(curl -sI https://github.com/aristocratos/btop/releases/latest | grep -i "^location:" | sed -E 's|.*/v([0-9.]+).*|\1|')
        curl -Lo /tmp/btop.tbz "https://github.com/aristocratos/btop/releases/download/v${BTOP_VERSION}/btop-x86_64-unknown-linux-musl.tbz"
        tar xjf /tmp/btop.tbz -C /tmp
        install /tmp/btop/bin/btop "$HOME/.local/bin"
        rm -rf /tmp/btop.tbz /tmp/btop
        print_success "btop installed"
    else
        print_success "btop already installed ($(btop --version))"
    fi

    # Install tectonic (lightweight LaTeX for snacks.nvim math rendering)
    if ! command -v tectonic &> /dev/null; then
        print_info "Installing tectonic..."
        # Tectonic uses tag format "tectonic@VERSION" and includes version in filename
        TECTONIC_VERSION=$(curl -s https://api.github.com/repos/tectonic-typesetting/tectonic/releases/latest | grep '"tag_name"' | sed -E 's/.*"tectonic@([^"]+)".*/\1/')
        if [ -n "$TECTONIC_VERSION" ]; then
            curl -Lo /tmp/tectonic.tar.gz "https://github.com/tectonic-typesetting/tectonic/releases/download/tectonic%40${TECTONIC_VERSION}/tectonic-${TECTONIC_VERSION}-x86_64-unknown-linux-gnu.tar.gz"
            tar xf /tmp/tectonic.tar.gz -C /tmp
            install /tmp/tectonic "$HOME/.local/bin"
            rm -rf /tmp/tectonic.tar.gz /tmp/tectonic
            print_success "tectonic ${TECTONIC_VERSION} installed"
        else
            print_error "Failed to fetch tectonic version"
            print_info "Manual installation: https://tectonic-typesetting.github.io/book/latest/installation/"
        fi
    else
        print_success "tectonic already installed ($(tectonic --version | head -1))"
    fi

    # Note: ghostscript (gs) requires system packages for PDF rendering in snacks.nvim
    # Install with: sudo apt-get install ghostscript (Debian/Ubuntu)
    if ! command -v gs &> /dev/null; then
        print_info "ghostscript (gs) not found - PDF rendering in snacks.nvim requires system package"
        print_info "Install with: sudo apt-get install ghostscript"
    else
        print_success "ghostscript already installed"
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

    # Install mermaid-cli for snacks.nvim diagram rendering (requires pnpm)
    if command -v pnpm &> /dev/null; then
        if ! command -v mmdc &> /dev/null; then
            print_info "Installing mermaid-cli (for snacks.nvim diagram rendering)..."
            pnpm add -g @mermaid-js/mermaid-cli
            print_success "mermaid-cli installed"
        else
            print_success "mermaid-cli already installed"
        fi
    fi

    print_info "Continuing with configuration setup..."
fi

# Install Claude Code (native installer with auto-updates)
# Skip in containers - should be installed in Dockerfile instead
if ! $IS_CONTAINER; then
    if ! command -v claude &> /dev/null; then
        print_info "Installing Claude Code..."
        curl -fsSL https://claude.ai/install.sh | bash
        print_success "Claude Code installed"
    else
        CLAUDE_VERSION=$(claude --version 2>/dev/null | head -1 || echo "unknown")
        print_success "Claude Code already installed ($CLAUDE_VERSION)"
    fi
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

# Install fzf-tab (fzf-powered completion menu)
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fzf-tab" ]; then
    print_info "Installing fzf-tab..."
    git clone https://github.com/Aloxaf/fzf-tab ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fzf-tab
    print_success "fzf-tab installed"
else
    print_success "fzf-tab already installed"
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
# In containers, uv can't hardlink across filesystems - use copy mode
UV_LINK_MODE_FLAG=""
$IS_CONTAINER && UV_LINK_MODE_FLAG="--link-mode=copy"

if command -v uv &> /dev/null; then
    uv pip install $UV_LINK_MODE_FLAG --python "$TMUX_PYTHON_ENV/bin/python" libtmux
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
        # Only remove symlinks that don't point into dotfiles (stow-managed)
        local link_target
        link_target=$(readlink "$target" 2>/dev/null || true)
        if [[ "$link_target" != *"dotfiles"* ]]; then
            rm "$target"  # Remove old symlinks so stow can recreate them
        fi
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

# Handle terminfo files that may have been created manually (e.g., by Ghostty)
backup_if_exists "$HOME/.terminfo/x/xterm-ghostty"
backup_if_exists "$HOME/.terminfo/g/ghostty"

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
stow_package "claude"

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
# Skip in containers - .gitconfig is bind-mounted from host and already configured
if [ -f "$DOTFILES_DIR/git/config" ] && ! $IS_CONTAINER; then
    INCLUDE_PATH="$DOTFILES_DIR/git/config"
    if ! grep -q "path = $INCLUDE_PATH" "$HOME/.gitconfig" 2>/dev/null; then
        git config --global include.path "$INCLUDE_PATH"
        print_success "Added git config include"
    else
        print_success "Git config include already present"
    fi
fi

# Enable git fsmonitor for faster git status in large repos (macOS only)
if $IS_MAC; then
    if [ "$(git config --global core.fsmonitor)" != "true" ]; then
        git config --global core.fsmonitor true
        git config --global core.untrackedCache true
        print_success "Enabled git fsmonitor (faster git status)"
    else
        print_success "Git fsmonitor already enabled"
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

        # Install/update ghostty shaders from external repos
        GHOSTTY_SHADERS_DIR="$DOTFILES_DIR/ghostty/.config/ghostty/shaders"
        mkdir -p "$GHOSTTY_SHADERS_DIR"

        # In-Game CRT shader (sarphiv/ghostty-shader-in-game-crt)
        print_info "Updating in-game CRT shaders..."
        TEMP_CRT_DIR="/tmp/ghostty-shader-in-game-crt"
        rm -rf "$TEMP_CRT_DIR"
        git clone --depth=1 https://github.com/sarphiv/ghostty-shader-in-game-crt.git "$TEMP_CRT_DIR"
        cp "$TEMP_CRT_DIR/src/"*.glsl "$GHOSTTY_SHADERS_DIR/"
        rm -rf "$TEMP_CRT_DIR"
        print_success "In-game CRT shaders updated"
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

        # Install sketchybar-app-font (custom app icons)
        print_info "Setting up sketchybar-app-font..."

        # Ensure pnpm is installed
        if ! command -v pnpm &> /dev/null; then
            print_info "Installing pnpm..."
            brew install pnpm
            print_success "pnpm installed"
        fi

        # Clone and build sketchybar-app-font
        TEMP_FONT_DIR="/tmp/sketchybar-app-font-install"
        if [ -d "$TEMP_FONT_DIR" ]; then
            rm -rf "$TEMP_FONT_DIR"
        fi

        git clone --depth=1 https://github.com/kvndrsslr/sketchybar-app-font.git "$TEMP_FONT_DIR"
        cd "$TEMP_FONT_DIR"
        pnpm install --silent

        # Create template for generated mappings (separate file to keep repo clean)
        cat > "$HOME/.config/sketchybar/plugins/icon_map_generated_template.sh" << 'GEN_TEMPLATE'
#!/bin/bash
# Auto-generated by sketchybar-app-font - do not edit manually

### START-OF-ICON-MAP
# The icon map function will be auto-generated here by build:install
### END-OF-ICON-MAP
GEN_TEMPLATE

        # Generate mappings into separate file (not in repo)
        pnpm run build:install "$HOME/.config/sketchybar/plugins/icon_map_generated_template.sh" 2>&1 | grep -E "(SUCCESS|Successfully)" || true
        mv "$HOME/.config/sketchybar/plugins/icon_map_generated_template.sh" "$HOME/.config/sketchybar/plugins/icon_map_generated.sh"

        # Install font to system
        cp dist/sketchybar-app-font.ttf "$HOME/Library/Fonts/"

        cd "$DOTFILES_DIR"
        rm -rf "$TEMP_FONT_DIR"
        print_success "sketchybar-app-font installed (441 custom app icons)"

        brew services restart sketchybar 2>/dev/null || true
        print_success "SketchyBar service started"
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

    # OrionFocusMode.app (for quarto-preview SSH accessibility)
    if [ -d "$DOTFILES_DIR/macos/Applications/OrionFocusMode.app" ]; then
        print_success "OrionFocusMode.app found in dotfiles"
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
uv pip install $UV_LINK_MODE_FLAG --python "$NVIM_PYTHON_ENV/bin/python" pynvim cairosvg pillow
print_success "Python packages installed to nvim venv"

# Install R packages for LSP and development (if R is available)
# Data science packages (tidyverse, etc.) are installed per-project via renv
if command -v Rscript &> /dev/null; then
    print_info "Installing R packages (pak, languageserver, lintr, styler, devtools, here, renv)..."
    # Install pak from r-lib repo for binary support on new R versions
    Rscript -e 'if (!require("pak")) install.packages("pak", repos = sprintf("https://r-lib.github.io/p/pak/stable/%s/%s/%s", .Platform$pkgType, R.Version()$os, R.Version()$arch))'
    # Install dev tooling via pak for speed
    Rscript -e 'pak::pak(c("languageserver", "lintr", "styler", "devtools", "here", "renv"))'
    print_success "R packages installed"
else
    print_info "R not found - skipping R package installation"
    print_info "After installing R, run: Rscript -e 'pak::pak(c(\"languageserver\", \"lintr\", \"styler\", \"devtools\", \"here\", \"renv\"))'"
fi

# Install Mason packages for neovim (LSP servers, formatters, etc.)
if command -v nvim &> /dev/null; then
    print_info "Installing Mason packages (air formatter)..."
    nvim --headless "+MasonInstall air" "+qa"
    print_success "Mason packages installed"
fi

# Create symlinks for Mason LSP binaries (makes them available to Claude Code)
MASON_BIN="$HOME/.local/share/nvim/mason/bin"
if [ -d "$MASON_BIN" ]; then
    print_info "Creating LSP symlinks for Claude Code..."
    mkdir -p "$HOME/.local/bin"
    for lsp in lua-language-server pyright-langserver; do
        if [ -x "$MASON_BIN/$lsp" ]; then
            ln -sf "$MASON_BIN/$lsp" "$HOME/.local/bin/$lsp"
            print_success "Linked $lsp"
        fi
    done
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

# Permissions Summary (macOS only)
if $IS_MAC && ! $IS_SSH; then
    echo ""
    print_info "⚠️  PERMISSIONS REQUIRED (macOS)"
    echo ""
    echo "To enable all features, grant the following permissions in System Settings:"
    echo ""
    echo "1. Accessibility Permissions:"
    echo "   System Settings → Privacy & Security → Accessibility"
    echo ""

    # Check if OrionFocusMode exists
    if [ -d "$DOTFILES_DIR/macos/Applications/OrionFocusMode.app" ]; then
        echo "   • Add: ~/dotfiles/macos/Applications/OrionFocusMode.app"
        echo "     (Enables quarto-preview to hide Orion's menu bar)"
        echo ""
    fi

    # Check if Terminal or other terminal apps need permissions
    echo "   • Add your Terminal app (e.g., Terminal.app, Ghostty.app, iTerm.app)"
    echo "     (Enables quarto-preview function to control Orion windows)"
    echo ""

    # Check if AeroSpace is installed
    if command -v aerospace &> /dev/null || [ -d "/Applications/AeroSpace.app" ]; then
        echo "2. Screen Recording Permission (for AeroSpace):"
        echo "   System Settings → Privacy & Security → Screen Recording"
        echo "   • Enable: AeroSpace.app"
        echo "     (Required for window management and workspace detection)"
        echo ""
    fi

    echo "Note: You'll be prompted to grant these permissions when first using the features."
    echo "      Restart the affected applications after granting permissions."
    echo ""
fi
