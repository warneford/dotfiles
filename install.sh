#!/bin/bash

set -e

echo "🚀 Starting dotfiles installation..."

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

# Check for Homebrew and install dependencies
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
    "r"             # R language
    "ripgrep"       # Required for Telescope fuzzy finder
    "neovim"        # Neovim editor
)

for dep in "${DEPENDENCIES[@]}"; do
    if brew list "$dep" &> /dev/null; then
        print_success "$dep already installed"
    else
        print_info "Installing $dep..."
        brew install "$dep"
        print_success "$dep installed"
    fi
done

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

echo ""
print_success "Installation complete!"
echo ""
print_info "Next steps:"
echo "  1. Restart your terminal or run: source ~/.zshrc"
echo "  2. Run 'p10k configure' to configure your Powerlevel10k theme"
echo "  3. Open nvim - lazy.nvim will auto-install and plugins will be loaded"
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
