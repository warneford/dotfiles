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

# Carapace - multi-shell completion engine with rich descriptions
# Provides completions for 1000+ CLI tools with descriptions and grouping
# https://carapace.sh/
if command -v carapace &> /dev/null; then
    export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'
    source <(carapace _carapace)
fi

# Better path expansion (e.g., /u/l/b -> /usr/local/bin)
zstyle ':completion:*' expand 'yes'
zstyle ':completion:*' squeeze-slashes 'yes'

# Auto-complete hidden files (dotfiles)
# Note: This doesn't work well with fzf-tab + zsh-autosuggestions combo
# Use fzf directly (Ctrl+T) for hidden file search
_comp_options+=(globdots)

# ============================================================================
# fzf-tab Configuration
# ============================================================================
# fzf-tab replaces zsh's default completion menu with fzf
# https://github.com/Aloxaf/fzf-tab

# Disable default zsh completion menu (let fzf-tab handle it)
zstyle ':completion:*' menu no

# fzf-tab styling - rounded border with solid background
zstyle ':fzf-tab:*' fzf-flags \
    --color=bg+:#3b4261,bg:#1a1b26,border:#7aa2f7 \
    --color=fg:#a9b1d6,fg+:#c0caf5,header:#9ece6a \
    --color=hl:#7aa2f7,hl+:#bb9af7 \
    --color=pointer:#bb9af7,marker:#e0af68,prompt:#7dcfff \
    --color=info:#7aa2f7,spinner:#bb9af7 \
    --border=rounded \
    --padding=0,1

# Adjust padding for border (required when using --border)
zstyle ':fzf-tab:*' fzf-pad 4

# Disable the dot prefix for group colors (cleaner look)
zstyle ':fzf-tab:*' prefix ''

# Default: no preview (keeps command completions clean)
zstyle ':fzf-tab:*' fzf-preview

# Preview for file/directory navigation commands (include hidden files with -a)
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls -la --color=always $realpath 2>/dev/null'
zstyle ':fzf-tab:complete:ls:*' fzf-preview 'ls -la --color=always $realpath 2>/dev/null'
zstyle ':fzf-tab:complete:cat:*' fzf-preview 'head -100 $realpath 2>/dev/null'
zstyle ':fzf-tab:complete:less:*' fzf-preview 'head -100 $realpath 2>/dev/null'
zstyle ':fzf-tab:complete:nvim:*' fzf-preview '[[ -d $realpath ]] && ls -la --color=always $realpath || head -100 $realpath 2>/dev/null'
zstyle ':fzf-tab:complete:vim:*' fzf-preview '[[ -d $realpath ]] && ls -la --color=always $realpath || head -100 $realpath 2>/dev/null'

# Switch between completion groups with < and >
zstyle ':fzf-tab:*' switch-group '<' '>'

# Hide group headers (cleaner look)
zstyle ':fzf-tab:*' show-group none
