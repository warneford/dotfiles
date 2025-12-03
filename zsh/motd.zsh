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

  # Display image centered (kitty handles sizing automatically)
  kitten icat --align center ~/dotfiles/assets/galaxy_brain_man.jpg
}

if [[ "$HOSTNAME" == "rwt-mind-palace" ]]; then
  _show_motd
  unfunction _show_motd
fi
