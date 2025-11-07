# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

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

# Add any custom paths here
# Add Quarto to PATH (macOS cask install)
if [ -d "/Applications/quarto/bin" ]; then
    export PATH="/Applications/quarto/bin:$PATH"
fi

# Add Quarto to PATH (Linux install to ~/.local)
if [ -d "$HOME/.local/quarto/bin" ]; then
    export PATH="$HOME/.local/quarto/bin:$PATH"
fi

# Add bob-nvim (neovim version manager) to PATH
export PATH="$HOME/.local/share/bob/nvim-bin:$PATH"

# Add Rust/Cargo to PATH
export PATH="$HOME/.cargo/bin:$PATH"

# Load nvm (Node Version Manager) - check both common locations
if [ -d "$HOME/.config/nvm" ]; then
    export NVM_DIR="$HOME/.config/nvm"
elif [ -d "$HOME/.nvm" ]; then
    export NVM_DIR="$HOME/.nvm"
fi
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Add Python user bin to PATH
export PATH="$HOME/Library/Python/3.9/bin:$PATH"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Created by `pipx` on 2025-11-05 15:37:06
export PATH="$PATH:/Users/rwarne/.local/bin"
