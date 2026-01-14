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
        local ws=$(aerospace list-workspaces --focused 2>/dev/null)
        local orion_was_running=true
        # Close any existing localhost:9013 Orion window first
        local old_win=$(aerospace list-windows --all 2>/dev/null | grep -i "Orion.*localhost" | awk '{print $1}')
        [[ -n "$old_win" ]] && aerospace close --window-id "$old_win" 2>/dev/null
        # Launch Orion if not running
        if ! pgrep -q "Orion"; then
            orion_was_running=false
            open -a "Orion - Work"
            while ! pgrep -q "Orion"; do sleep 0.1; done
            for i in {1..30}; do
                if osascript -e 'tell application "Orion - Work" to return name' &>/dev/null; then
                    break
                fi
                sleep 0.2
            done
        fi
        # Open new window with URL
        osascript -e 'tell application "Orion - Work" to activate'
        # Only Cmd+N if Orion was already running (fresh launch already has a window)
        $orion_was_running && osascript -e 'tell application "System Events" to keystroke "n" using command down' && sleep 0.3
        osascript -e 'tell application "Orion - Work" to open location "http://localhost:9013"'
        sleep 0.3
        aerospace workspace "$ws" 2>/dev/null
        # Wait for localhost window to appear
        local win_id=""
        for i in {1..10}; do
            sleep 0.2
            win_id=$(aerospace list-windows --all 2>/dev/null | grep -i "Orion.*localhost" | head -1 | awk '{print $1}')
            [[ -n "$win_id" ]] && break
        done
        if [[ -n "$win_id" ]]; then
            aerospace move-node-to-workspace --window-id "$win_id" "$ws" 2>/dev/null
            aerospace focus --window-id "$win_id" 2>/dev/null
        fi
        osascript -e 'tell application "Orion - Work" to activate'
        # Apply menu settings (retry for SSH access)
        for attempt in {1..5}; do
            sleep 0.5
            launchctl asuser $uid osascript -e 'tell application "System Events" to tell process "Orion" to click menu item "Enable Focus Mode" of menu "View" of menu bar 1' 2>/dev/null
            launchctl asuser $uid osascript -e 'tell application "System Events" to tell process "Orion" to click menu item "Hide Sidebar" of menu "View" of menu bar 1' 2>/dev/null && break
        done
    }
fi
