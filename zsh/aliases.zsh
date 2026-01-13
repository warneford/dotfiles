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
alias ls='ls -1'

# =============================================================================
# Platform-specific aliases
# =============================================================================

if [[ "$OSTYPE" == darwin* ]]; then
    # macOS
    alias R='/Library/Frameworks/R.framework/Resources/bin/R'
    alias down='cd ~/Downloads'
    function quarto-preview() {
        local ws=$(aerospace list-workspaces --focused)
        # Launch Orion if not running
        if ! pgrep -q "Orion"; then
            open -a "Orion - Work"
            while ! pgrep -q "Orion"; do sleep 0.1; done
            sleep 1
        fi
        open -a "Orion" "http://localhost:9013"
        sleep 0.2
        aerospace workspace "$ws" 2>/dev/null
        # Wait for window to appear
        local win_id=""
        for i in {1..10}; do
            sleep 0.2
            win_id=$(aerospace list-windows --all | grep -i "Orion.*localhost" | head -1 | awk '{print $1}')
            [[ -n "$win_id" ]] && break
        done
        if [[ -n "$win_id" ]]; then
            aerospace move-node-to-workspace --window-id "$win_id" "$ws" 2>/dev/null
            aerospace focus --window-id "$win_id"
            osascript -e 'tell application "Orion" to activate'
            sleep 0.5
            osascript -e 'tell application "System Events" to tell process "Orion"
                try
                    click menu item "Enable Focus Mode" of menu "View" of menu bar 1
                end try
            end tell'
        fi
    }
fi
