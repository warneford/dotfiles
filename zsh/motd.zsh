# Message of the day for container login
# Only show in the r-dev container (rwt-mind-palace)

_show_motd() {
  local cols=$(tput cols)
  local color=$'\e[38;2;255;0;179m'
  local reset=$'\e[0m'

  echo
  if [[ $cols -ge 84 ]]; then
    # Full horizontal version (84 cols wide)
    local art_width=84
    local pad=$(( (cols - art_width) / 2 ))
    [[ $pad -lt 0 ]] && pad=0
    while IFS= read -r line; do
      printf '%*s%s%s%s\n' $pad '' "$color" "$line" "$reset"
    done << 'EOF'
███╗   ███╗██╗███╗   ██╗██████╗     ██████╗  █████╗ ██╗      █████╗  ██████╗███████╗
████╗ ████║██║████╗  ██║██╔══██╗    ██╔══██╗██╔══██╗██║     ██╔══██╗██╔════╝██╔════╝
██╔████╔██║██║██╔██╗ ██║██║  ██║    ██████╔╝███████║██║     ███████║██║     █████╗
██║╚██╔╝██║██║██║╚██╗██║██║  ██║    ██╔═══╝ ██╔══██║██║     ██╔══██║██║     ██╔══╝
██║ ╚═╝ ██║██║██║ ╚████║██████╔╝    ██║     ██║  ██║███████╗██║  ██║╚██████╗███████╗
╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝╚═════╝     ╚═╝     ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝ ╚═════╝╚══════╝
EOF
  else
    # Compact stacked version (48 cols wide)
    local art_width=48
    local pad=$(( (cols - art_width) / 2 ))
    [[ $pad -lt 0 ]] && pad=0
    while IFS= read -r line; do
      printf '%*s%s%s%s\n' $pad '' "$color" "$line" "$reset"
    done << 'EOF'
███╗   ███╗██╗███╗   ██╗██████╗
████╗ ████║██║████╗  ██║██╔══██╗
██╔████╔██║██║██╔██╗ ██║██║  ██║
██║╚██╔╝██║██║██║╚██╗██║██║  ██║
██║ ╚═╝ ██║██║██║ ╚████║██████╔╝
╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝╚═════╝
██████╗  █████╗ ██╗      █████╗  ██████╗███████╗
██╔══██╗██╔══██╗██║     ██╔══██╗██╔════╝██╔════╝
██████╔╝███████║██║     ███████║██║     █████╗
██╔═══╝ ██╔══██║██║     ██╔══██║██║     ██╔══╝
██║     ██║  ██║███████╗██║  ██║╚██████╗███████╗
╚═╝     ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝ ╚═════╝╚══════╝
EOF
  fi
  echo

  # Display image using kitten icat (kitty graphics protocol)
  # TMUX_PASSTHROUGH is set via SSH SetEnv when connecting from inside local tmux
  # --transfer-mode=stream sends data via escape codes (needed over SSH)
  # --unicode-placeholder is required for tmux (can't track cursor position)
  # --passthrough=tmux wraps escape sequences for tmux
  # TMUX= unsets the socket path so kitten doesn't try to verify passthrough setting
  if [[ -n "$TMUX_PASSTHROUGH" ]]; then
    TMUX= kitten icat --transfer-mode=stream --passthrough=tmux --unicode-placeholder --align=center ~/dotfiles/assets/galaxy_brain_man.jpg
  else
    kitten icat --align=center ~/dotfiles/assets/galaxy_brain_man.jpg
  fi
}

if [[ "$(hostname)" == "rwt-mind-palace" ]]; then
  _show_motd
  unfunction _show_motd
fi
