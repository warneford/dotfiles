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
        local uid=$(id -u)
        local ws="1"  # Dev workspace
        # Close any existing localhost:9013 Orion window first
        local old_win=$(aerospace list-windows --all 2>/dev/null | grep -i "Orion.*localhost" | awk '{print $1}')
        [[ -n "$old_win" ]] && aerospace close --window-id "$old_win" 2>/dev/null
        # Launch Orion if not running
        if pgrep -q "Orion"; then
            # Orion already running - Cmd+N for new window, then navigate
            osascript -e 'tell application "Orion - Work" to activate'
            osascript -e 'tell application "System Events" to keystroke "n" using command down'
            sleep 0.3
            osascript -e 'tell application "Orion - Work" to open location "http://localhost:9013"'
        else
            # Launch Orion fresh with URL (single window)
            open "http://localhost:9013" -a "Orion - Work"
            while ! pgrep -q "Orion"; do sleep 0.1; done
            for i in {1..30}; do
                osascript -e 'tell application "Orion - Work" to return name' &>/dev/null && break
                sleep 0.2
            done
        fi
        sleep 0.5
        # Wait for localhost window and move to target workspace
        local win_id=""
        for i in {1..15}; do
            sleep 0.2
            win_id=$(aerospace list-windows --all 2>/dev/null | grep -i "Orion.*localhost" | head -1 | awk '{print $1}')
            [[ -n "$win_id" ]] && break
        done
        if [[ -n "$win_id" ]]; then
            aerospace move-node-to-workspace --window-id "$win_id" "$ws" 2>/dev/null
            aerospace focus --window-id "$win_id" 2>/dev/null
        fi
        osascript -e 'tell application "Orion - Work" to activate'
        # Apply menu settings via app bundle (has accessibility permissions)
        sleep 0.5
        open -g ~/dotfiles/macos/Applications/OrionFocusMode.app 2>/dev/null
    }
fi
