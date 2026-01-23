#!/bin/bash
# Maps app names to icons using sketchybar-app-font with custom fallbacks
# App-font library: https://github.com/kvndrsslr/sketchybar-app-font

# Source the generated icon map function (created during install)
ICON_MAP_GEN="$HOME/.config/sketchybar/plugins/icon_map_generated.sh"
if [ -f "$ICON_MAP_GEN" ]; then
  source "$ICON_MAP_GEN"
fi

# Try the app-font mapping first
__icon_map "$1" 2>/dev/null || true

# If app-font didn't find it (returns default icon), check our custom fallbacks
if [ "$icon_result" = "" ] || [ "$icon_result" = ":default:" ]; then
  case "$1" in
  "Finder")
    icon_result="󰀶"
    ;;
  "Safari" | "Safari Technology Preview")
    icon_result="󰀹"
    ;;
  "Google Chrome" | "Chromium" | "Chrome")
    icon_result="󰊯"
    ;;
  "Firefox" | "Firefox Developer Edition")
    icon_result="󰈹"
    ;;
  "Orion" | "Orion Browser")
    icon_result="󰫢"
    ;;
  "Brave Browser")
    icon_result="󰖟"
    ;;
  "Arc")
    icon_result="󰞍"
    ;;
  "Terminal" | "iTerm2" | "Alacritty" | "kitty" | "WezTerm")
    icon_result="󰆍"
    ;;
  "Ghostty")
    icon_result="󰊠"
    ;;
  "Code" | "Visual Studio Code" | "VSCodium")
    icon_result="󰨞"
    ;;
  "Neovide" | "MacVim" | "Vim" | "VimR")
    icon_result="󰕷"
    ;;
  "Xcode")
    icon_result="󰀵"
    ;;
  "Slack")
    icon_result="󰒱"
    ;;
  "Discord")
    icon_result="󰙯"
    ;;
  "Messages")
    icon_result="󰍡"
    ;;
  "Mail")
    icon_result="󰇮"
    ;;
  "Calendar" | "Fantastical")
    icon_result="󰃭"
    ;;
  "Notes")
    icon_result="󰎞"
    ;;
  "Reminders")
    icon_result="󰃀"
    ;;
  "Music")
    icon_result="󰎆"
    ;;
  "Spotify")
    icon_result="󰓇"
    ;;
  "Preview" | "Skim")
    icon_result="󰈙"
    ;;
  "System Preferences" | "System Settings")
    icon_result="󰒓"
    ;;
  "Notion")
    icon_result=""
    ;;
  "Obsidian")
    icon_result="󱓧"
    ;;
  "Figma")
    icon_result="󰡡"
    ;;
  "Sketch")
    icon_result="󰴓"
    ;;
  "zoom.us" | "Zoom")
    icon_result="󰍫"
    ;;
  "Microsoft Teams")
    icon_result="󰊻"
    ;;
  "Microsoft Word")
    icon_result="󰈬"
    ;;
  "Microsoft Excel")
    icon_result="󰈛"
    ;;
  "Microsoft PowerPoint")
    icon_result="󰈧"
    ;;
  "Docker" | "Docker Desktop")
    icon_result="󰡨"
    ;;
  "Postman")
    icon_result="󰛮"
    ;;
  "RStudio" | "Positron")
    icon_result="󰟔"
    ;;
  "Activity Monitor")
    icon_result="󰍛"
    ;;
  "1Password" | "Bitwarden")
    icon_result="󰌋"
    ;;
  "Flighty")
    icon_result="󰀝"
    ;;
  *)
    icon_result="󰘔"
    ;;
  esac
fi

echo "$icon_result"
