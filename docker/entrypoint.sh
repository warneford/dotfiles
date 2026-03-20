#!/bin/bash
# Entrypoint for r-dev container
# Runs dotfiles install script on first start, then executes CMD

# Start SSH server (needs sudo since we run as non-root user)
sudo /usr/sbin/sshd

# Create symlink to projects in home directory (mounted at /data/home/... for venv compatibility)
if [ -d "/data/home/$(whoami)/projects" ] && [ ! -e "$HOME/projects" ]; then
    ln -s "/data/home/$(whoami)/projects" "$HOME/projects"
fi

INSTALL_MARKER="$HOME/.dotfiles-installed"

if [ ! -f "$INSTALL_MARKER" ] && [ -f "$HOME/dotfiles/install.sh" ]; then
    echo "First run - setting up dotfiles..."
    cd "$HOME/dotfiles"
    bash install.sh
    touch "$INSTALL_MARKER"
    echo "Dotfiles setup complete!"

    # Sync neovim plugins on first boot
    # Mason tools install automatically on first interactive nvim launch
    echo "Syncing neovim plugins..."
    nvim --headless "+Lazy! sync" +qa 2>/dev/null || true
    echo "Activating Supermaven free tier..."
    nvim --headless "+SupermavenUseFree" +qa 2>/dev/null || true
    echo "Neovim setup complete!"
fi

# Allow direnv and sync uv for any project with both .envrc and pyproject.toml
PROJECTS_DIR="$HOME/projects"
if [ -d "$PROJECTS_DIR" ]; then
    for dir in "$PROJECTS_DIR"/*/; do
        if [ -f "$dir/.envrc" ] && [ -f "$dir/pyproject.toml" ]; then
            echo "Setting up $(basename "$dir"): direnv allow + uv sync..."
            direnv allow "$dir"
            (cd "$dir" && uv sync 2>&1) || echo "  uv sync failed for $(basename "$dir"), skipping"
        fi
    done
fi

# Execute the CMD (default: zsh)
exec "$@"
