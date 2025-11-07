# Common aliases for all environments
# This file is symlinked to ~/.oh-my-zsh/custom/aliases.zsh

# Editor aliases
alias vim='nvim'
alias v='nvim'

# Git aliases
alias lg='lazygit'

# R aliases - use radian for enhanced console with RStudio-like features
alias R='radian'
alias r='radian'

# Convenience aliases
alias down='cd ~/Downloads'
alias new_alias='vim ~/dotfiles/zsh/aliases.zsh'

# tmux aliases
alias ta='tmux attach'
alias tn='tmux new-session -s'
alias tl='tmux list-sessions'
alias tk='tmux kill-session'

# SSH + tmux aliases (use full path to conda tmux for updated version)
alias tentacle='ssh -t robert@tentacle.octantbio.net "~/.local/miniforge3/envs/r-base/bin/tmux new -A -s main"'
