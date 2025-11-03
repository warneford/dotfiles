# ============================================================================
# Enhanced Path Completion Configuration
# ============================================================================
# Source this file from your .zshrc: source ~/.config/zsh/completion.zsh

# Enable completion system
autoload -Uz compinit && compinit

# Case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Menu-style completion (navigate with arrow keys)
zstyle ':completion:*' menu select

# Color completion listings (ls-style colors)
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Group completions by type
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%B%d%b'

# Use cache for faster completions
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

# Better file/directory completion
zstyle ':completion:*' file-sort modification
zstyle ':completion:*' special-dirs true

# Complete . and .. special directories
zstyle ':completion:*' special-dirs true

# Fuzzy matching for typos (e.g., /urs/local -> /usr/local)
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric

# Better path expansion (e.g., /u/l/b -> /usr/local/bin)
zstyle ':completion:*' expand 'yes'
zstyle ':completion:*' squeeze-slashes 'yes'

# Auto-complete hidden files (dotfiles)
_comp_options+=(globdots)
