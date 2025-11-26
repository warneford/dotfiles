#!/bin/bash
# Entrypoint for r-dev container
# Runs dotfiles install script on first start, then executes CMD

INSTALL_MARKER="$HOME/.dotfiles-installed"

if [ ! -f "$INSTALL_MARKER" ] && [ -f "$HOME/dotfiles/install.sh" ]; then
    echo "First run - setting up dotfiles..."
    cd "$HOME/dotfiles"
    bash install.sh
    touch "$INSTALL_MARKER"
    echo "Dotfiles setup complete!"
fi

# Execute the CMD (default: zsh)
exec "$@"
