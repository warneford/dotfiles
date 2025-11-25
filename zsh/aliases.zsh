# Common aliases for all environments
# This file is symlinked to ~/.oh-my-zsh/custom/aliases.zsh

# Editor aliases
alias vim='nvim'
alias v='nvim'

# Git aliases
alias lg='lazygit'

# R aliases
# R (uppercase) = system R for CMD operations like R CMD INSTALL
# r (lowercase) = radian for enhanced console with RStudio-like features
alias R='/Library/Frameworks/R.framework/Resources/bin/R'
alias r='radian'

# Convenience aliases
alias down='cd ~/Downloads'
alias new_alias='vim ~/dotfiles/zsh/aliases.zsh'

# tmux aliases
alias ta='tmux attach'
alias tn='tmux new-session -s'
alias tl='tmux list-sessions'
alias tk='tmux kill-session'
