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
        # Launch Orion if not running
        if ! pgrep -q "Orion"; then
            open -a "Orion - Work"
            while ! pgrep -q "Orion"; do sleep 0.1; done
            # Wait for Orion to be scriptable
            for i in {1..30}; do
                if osascript -e 'tell application "Orion - Work" to return name' &>/dev/null; then
                    break
                fi
                sleep 0.2
            done
        fi
        osascript -e 'tell application "Orion - Work" to open location "http://localhost:9013"'
        sleep 0.2
        aerospace workspace "$ws" 2>/dev/null
        # Wait for window to appear
        local win_id=""
        for i in {1..10}; do
            sleep 0.2
            win_id=$(aerospace list-windows --all 2>/dev/null | grep -i "Orion.*localhost" | head -1 | awk '{print $1}')
            [[ -n "$win_id" ]] && break
        done
        if [[ -n "$win_id" ]]; then
            aerospace move-node-to-workspace --window-id "$win_id" "$ws" 2>/dev/null
            aerospace focus --window-id "$win_id" 2>/dev/null
            osascript -e 'tell application "Orion - Work" to activate'
            # Retry menu manipulation with launchctl for GUI session access (needed for SSH)
            for attempt in {1..5}; do
                sleep 0.5
                if launchctl asuser $uid osascript -e 'tell application "System Events" to tell process "Orion"
                    set viewMenu to menu "View" of menu bar 1
                    if exists menu item "Enable Focus Mode" of viewMenu then click menu item "Enable Focus Mode" of viewMenu
                    if exists menu item "Hide Sidebar" of viewMenu then click menu item "Hide Sidebar" of viewMenu
                end tell' 2>/dev/null; then
                    break
                fi
            done
        fi
    }
fi
