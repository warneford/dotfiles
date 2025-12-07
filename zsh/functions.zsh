# Custom shell functions
# This file is symlinked to ~/.oh-my-zsh/custom/functions.zsh

# Remote clipboard image paste for Claude Code
# Fetches image from Mac clipboard via reverse SSH tunnel and inserts path
# Only enabled inside the container (rwt-mind-palace)
if [[ "$(hostname)" == "rwt-mind-palace" ]]; then
    paste-image-widget() {
        local image_path
        image_path=$(paste-image 2>/dev/null)
        if [[ -n "$image_path" ]]; then
            LBUFFER+="$image_path"
            zle redisplay
        else
            zle -M "No image in clipboard or connection failed"
        fi
    }
    zle -N paste-image-widget
    # Bind to Ctrl+Shift+V (escape sequence may vary by terminal)
    # Ghostty uses CSI u encoding: lowercase v (118) with modifier 6 (Ctrl+Shift)
    bindkey '\e[118;6u' paste-image-widget
    # Uppercase V (86) variant
    bindkey '\e[86;6u' paste-image-widget
    # Common legacy alternatives
    bindkey '\e[V' paste-image-widget
fi

# Initialize a directory with direnv + uv for Python development
# Usage: uvinit [project-name]
#   - Creates .envrc with use_uv
#   - Creates pyproject.toml from template
#   - Opens pyproject.toml in nvim for editing
#   - Runs uv sync automatically on save (via nvim autocmd)
uvinit() {
    local project_name="${1:-$(basename "$PWD")}"
    local template_dir="$HOME/dotfiles/templates"

    # Check if already initialized
    if [ -f ".envrc" ]; then
        echo "Error: .envrc already exists in this directory"
        return 1
    fi

    # Create .envrc
    echo "use_uv" > .envrc
    echo "✓ Created .envrc"

    # Create pyproject.toml from template if it doesn't exist
    if [ ! -f "pyproject.toml" ]; then
        if [ -f "$template_dir/pyproject.toml" ]; then
            sed "s/PROJECT_NAME/$project_name/" "$template_dir/pyproject.toml" > pyproject.toml
            echo "✓ Created pyproject.toml"
        else
            echo "Warning: Template not found at $template_dir/pyproject.toml"
            return 1
        fi
    else
        echo "→ pyproject.toml already exists, skipping"
    fi

    # Allow direnv
    direnv allow .
    echo "✓ Allowed direnv"

    echo ""
    echo "Opening pyproject.toml - edit dependencies, then :wq to save and sync"
    echo ""

    # Open in nvim with autocmd to run uv sync on save
    nvim -c "autocmd BufWritePost <buffer> !uv sync" pyproject.toml

    echo ""
    echo "✓ Done! radian is now available in this directory."
}
