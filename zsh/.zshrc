# Powerlevel10k instant prompt - DISABLED temporarily to fix login hangs
# The instant prompt was causing issues with SSH logins and tmux panes
# To re-enable: uncomment the block below after debugging
#
# if [[ -z "$ZSHRC_RELOADING" && -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#   source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
# fi

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# Load enhanced completion settings
source ~/dotfiles/zsh/completion.zsh

# User configuration

# XDG Base Directory Specification
export XDG_CONFIG_HOME="$HOME/.config"

# Export preferred editor
export EDITOR='nvim'
export VISUAL='nvim'

# Custom PATH management - add directories only if not already in PATH
# This function prevents PATH pollution when .zshrc is sourced multiple times
add_to_path() {
    if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
        export PATH="$1:$PATH"
    fi
}

# Add Quarto to PATH (platform-specific)
if [[ "$OSTYPE" == "darwin"* ]]; then
    add_to_path "/Applications/quarto/bin"  # macOS Homebrew install
else
    add_to_path "$HOME/.local/quarto/bin"   # Linux manual install
fi

# Add bob-nvim (neovim version manager) to PATH
add_to_path "$HOME/.local/share/bob/nvim-bin"

# Add Rust/Cargo to PATH
add_to_path "$HOME/.cargo/bin"

# Load nvm (Node Version Manager) - check both common locations
if [ -d "$HOME/.config/nvm" ]; then
    export NVM_DIR="$HOME/.config/nvm"
elif [ -d "$HOME/.nvm" ]; then
    export NVM_DIR="$HOME/.nvm"
fi
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Add Python user bin to PATH (platform-specific)
if [[ "$OSTYPE" == "darwin"* ]]; then
    add_to_path "$HOME/Library/Python/3.9/bin"
    add_to_path "$HOME/.local/bin"
else
    # Linux
    add_to_path "$HOME/.local/bin"
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Add user-local R to PATH (from install-r-linux.sh)
add_to_path "$HOME/.local/R/current/bin"

# Alias for safely reloading .zshrc (skips instant prompt on reload)
alias reload='ZSHRC_RELOADING=1 source ~/.zshrc && unset ZSHRC_RELOADING'

# direnv hook for uv + per-project Python environments
eval "$(direnv hook zsh)"
