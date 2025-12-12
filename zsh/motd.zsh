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

  # Display a random image from assets folder
  local assets_dir=~/dotfiles/assets
  local images=("$assets_dir"/*.{jpg,jpeg,png,gif}(N))
  if (( ${#images[@]} > 0 )); then
    local random_image=${images[$((RANDOM % ${#images[@]} + 1))]}
    kitten icat --align center "$random_image"
  fi
}

if [[ "$(hostname)" == "rwt-mind-palace" && -z "$NVIM_TERMINAL" ]]; then
  _show_motd
  unfunction _show_motd
fi
