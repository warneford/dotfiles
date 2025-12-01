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
    function quarto-preview() {
        local ws=$(aerospace list-workspaces --focused)
        osascript -e 'tell application "Orion" to make new document with properties {URL:"http://localhost:9013"}'
        sleep 0.3
        # Switch back to original workspace immediately
        aerospace workspace "$ws"
        # Wait for window to appear in aerospace
        local win_id=""
        for i in {1..10}; do
            sleep 0.3
            win_id=$(aerospace list-windows --all | grep -i "Orion.*localhost" | head -1 | awk '{print $1}')
            [[ -n "$win_id" ]] && break
        done
        if [[ -n "$win_id" ]]; then
            aerospace move-node-to-workspace --window-id "$win_id" "$ws"
            aerospace focus --window-id "$win_id"
            sleep 0.3
            osascript -e 'tell application "Orion" to activate' \
                      -e 'tell application "System Events" to tell process "Orion" to click menu item "Enter Focus Mode" of menu "View" of menu bar 1'
        else
            echo "Could not find Orion localhost window"
        fi
    }
fi
