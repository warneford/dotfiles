# FZF-powered functions
# Sourced by .zshrc

# fcd - fuzzy cd into directory
fcd() {
    local dir search_paths
    search_paths=($(get_search_paths))
    dir=$(find "${search_paths[@]}" -type d -not -path '*/.*' 2>/dev/null | fzf --preview 'ls -la {}') && cd "$dir" && ls
}

# f - fuzzy find file, copy path to clipboard
f() {
    local file search_paths
    search_paths=($(get_search_paths))
    file=$(find "${search_paths[@]}" -type f -not -path '*/.*' 2>/dev/null | fzf --preview '_fzf_preview {}')
    [ -n "$file" ] && echo "$file" | pbcopy && echo "Copied: $file"
}

# fv - fuzzy find file and open in nvim
fv() {
    local file search_paths
    search_paths=($(get_search_paths))
    file=$(find "${search_paths[@]}" -type f -not -path '*/.*' 2>/dev/null | fzf --preview '_fzf_preview {}')
    [ -n "$file" ] && nvim "$file"
}

# fo - fuzzy find file and open with system default app
fo() {
    local file search_paths
    search_paths=($(get_search_paths))
    file=$(find "${search_paths[@]}" -type f -not -path '*/.*' 2>/dev/null | fzf --preview '_fzf_preview {}')
    if [ -n "$file" ]; then
        if [[ "$OSTYPE" == darwin* ]]; then
            open "$file"
        else
            xdg-open "$file" 2>/dev/null
        fi
    fi
}

# ff - fuzzy find and focus any aerospace window
ff() {
    aerospace list-windows --all | fzf --bind 'enter:execute(zsh -c "aerospace focus --window-id {1}")+abort'
}
