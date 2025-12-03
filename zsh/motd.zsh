# Message of the day for container login
# Only show in the r-dev container (rwt-mind-palace)

if [[ "$HOSTNAME" == "rwt-mind-palace" ]]; then
  local cols=$(tput cols)

  # Center helper function
  print_centered() {
    local text="$1"
    local width=${#text}
    local pad=$(( (cols - width) / 2 ))
    [[ $pad -lt 0 ]] && pad=0
    printf '%*s%s\n' $pad '' "$text"
  }

  echo
  if [[ $cols -ge 84 ]]; then
    # Full horizontal version (84 cols wide)
    local art_width=84
    while IFS= read -r line; do
      print_centered "$line"
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
    while IFS= read -r line; do
      print_centered "$line"
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

  # Display image with width matching the ASCII art, centered
  local pad=$(( (cols - art_width) / 2 ))
  [[ $pad -lt 0 ]] && pad=0
  kitten icat --place "${art_width}x0@${pad},0" ~/dotfiles/assets/galaxy_brain_man.jpg
fi
