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
        local ws="1"  # Dev workspace
        local url="http://localhost:9013"
        local aerospace="/opt/homebrew/bin/aerospace"

        # Check for existing Orion window in dev workspace (includes error states like "Failed to open page")
        local existing_win=$($aerospace list-windows --workspace "$ws" 2>/dev/null | grep -iE "Orion.*(localhost|Failed to open)" | head -1 | awk '{print $1}')

        if [[ -n "$existing_win" ]]; then
            # Reuse existing localhost window - just focus and refresh
            $aerospace move-node-to-workspace --window-id "$existing_win" "$ws" 2>/dev/null
            $aerospace focus --window-id "$existing_win" 2>/dev/null
            osascript -e 'tell application "Orion" to activate'
            # Refresh the page
            osascript -e 'tell application "System Events" to keystroke "r" using command down'
        elif pgrep -q "Orion"; then
            # Orion running but no localhost window - open URL in new window
            osascript -e 'tell application "Orion" to activate'
            osascript -e 'tell application "System Events" to keystroke "n" using command down'
            sleep 0.3
            osascript -e "tell application \"Orion\" to open location \"$url\""
            # Wait for localhost window and move to workspace
            local win_id=""
            for i in {1..15}; do
                win_id=$($aerospace list-windows --all 2>/dev/null | grep -i "Orion.*localhost" | head -1 | awk '{print $1}')
                [[ -n "$win_id" ]] && break
                sleep 0.1
            done
            if [[ -n "$win_id" ]]; then
                $aerospace move-node-to-workspace --window-id "$win_id" "$ws" 2>/dev/null
                $aerospace focus --window-id "$win_id" 2>/dev/null
            fi
        else
            # Launch Orion fresh with URL
            open "$url" -a "Orion"
            while ! pgrep -q "Orion"; do sleep 0.1; done
            for i in {1..30}; do
                osascript -e 'tell application "Orion" to return name' &>/dev/null && break
                sleep 0.2
            done
            # Wait for localhost window and move to workspace
            local win_id=""
            for i in {1..15}; do
                win_id=$($aerospace list-windows --all 2>/dev/null | grep -i "Orion.*localhost" | head -1 | awk '{print $1}')
                [[ -n "$win_id" ]] && break
                sleep 0.1
            done
            if [[ -n "$win_id" ]]; then
                $aerospace move-node-to-workspace --window-id "$win_id" "$ws" 2>/dev/null
                $aerospace focus --window-id "$win_id" 2>/dev/null
            fi
        fi
        # Apply menu settings via app bundle (has accessibility permissions)
        open -g ~/dotfiles/macos/Applications/OrionFocusMode.app 2>/dev/null
    }
fi
