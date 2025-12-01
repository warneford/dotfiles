#!/bin/bash
# Maps app names to Nerd Font icons

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
  icon_result=""
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
echo "$icon_result"
