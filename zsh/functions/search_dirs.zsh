# Shared search directory configuration
# Used by fzf functions, telescope, and fzf-lua

# Directories to search when in $HOME
SEARCH_DIRS=(
    "$HOME/dotfiles"
    "$HOME/projects"
    "$HOME/Octant Dropbox"
)

# Helper function: returns search paths based on current directory
# - In $HOME: returns curated SEARCH_DIRS
# - Elsewhere: returns current directory
get_search_paths() {
    if [[ "$PWD" == "$HOME" ]]; then
        # Filter to only existing directories
        for dir in "${SEARCH_DIRS[@]}"; do
            [[ -d "$dir" ]] && echo "$dir"
        done
    else
        echo "."
    fi
}
