# Aliases for all environments
# This file is symlinked to ~/.oh-my-zsh/custom/aliases.zsh

# =============================================================================
# Generic aliases (all platforms)
# =============================================================================

# Editor
alias vim='nvim'
alias v='nvim'

# Git
alias lg='lazygit'

# R (radian for enhanced console)
alias r='radian'

# tmux
alias ta='tmux attach'
alias tn='tmux new-session -s'
alias tl='tmux list-sessions'
alias tk='tmux kill-session'

# Convenience
alias new_alias='vim ~/dotfiles/zsh/aliases.zsh'

# =============================================================================
# Platform-specific aliases
# =============================================================================

if [[ "$OSTYPE" == darwin* ]]; then
    # macOS
    alias R='/Library/Frameworks/R.framework/Resources/bin/R'
    alias down='cd ~/Downloads'
fi
