# Powerlevel10k instant prompt - DISABLED temporarily to fix login hangs
# The instant prompt was causing issues with SSH logins and tmux panes
# To re-enable: uncomment the block below after debugging
#
# if [[ -z "$ZSHRC_RELOADING" && -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#   source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
# fi

# Load environment variables from ~/.env (secrets, tokens, etc.)
[[ -f ~/.env ]] && source ~/.env

# Set GITHUB_PAT from gh CLI oauth token (used by R pak/remotes for GitHub API)
# Resolves fresh on each shell so it stays valid even if gh refreshes the token
if command -v gh &> /dev/null && gh auth status &> /dev/null; then
    export GITHUB_PAT="$(gh auth token 2>/dev/null)"
fi

# Force Ghostty detection for snacks.nvim image preview
# SSH + docker exec + tmux doesn't propagate TERM_PROGRAM from local Ghostty
export SNACKS_GHOSTTY=true

# Force remote/streaming mode for snacks.nvim images when in a Docker container
# Container file paths aren't accessible to the local terminal, so we need
# to stream image data instead of sending file paths
if [[ -f /.dockerenv ]]; then
    export SNACKS_SSH=true
fi

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Note: fzf-tab must be loaded BEFORE zsh-autosuggestions and zsh-syntax-highlighting
plugins=(
    fzf-tab
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

# Claude Code environment file (sources PATH etc. for LSP servers)
export CLAUDE_ENV_FILE="$HOME/.claude/env.sh"

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

# Add Mason (nvim package manager) bin to PATH for formatters/linters
add_to_path "$HOME/.local/share/nvim/mason/bin"

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

# Add dotfiles bin to PATH (r-dev, radian-direnv, etc.)
add_to_path "$HOME/dotfiles/bin"

# Alias for safely reloading .zshrc (skips instant prompt on reload)
alias reload='ZSHRC_RELOADING=1 source ~/.zshrc && unset ZSHRC_RELOADING'

# direnv hook for uv + per-project Python environments
eval "$(direnv hook zsh)"

# uv cache in projects directory (allows hardlinking to venvs)
# Use /data/home path if it exists (container), otherwise ~/projects (host)
if [[ -d "/data/home/$USER/projects" ]]; then
    export UV_CACHE_DIR="/data/home/$USER/projects/.cache/uv"
else
    export UV_CACHE_DIR="$HOME/projects/.cache/uv"
fi

# Source all function files from ~/dotfiles/zsh/functions/
for func_file in ~/dotfiles/zsh/functions/*.zsh(N); do
    source "$func_file"
done

# Show MOTD for container login
[[ -f ~/dotfiles/zsh/motd.zsh ]] && source ~/dotfiles/zsh/motd.zsh
export PATH="$HOME/bin:$PATH"
