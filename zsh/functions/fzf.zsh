# FZF-powered functions
# Sourced by .zshrc

# fcd - fuzzy cd into directory
fcd() {
    local dir
    dir=$(find . -type d -not -path '*/.*' 2>/dev/null | fzf --preview 'ls -la {}') && cd "$dir" && ls
}

# f - fuzzy find file, copy path to clipboard
f() {
    local file
    file=$(find . -type f -not -path '*/.*' 2>/dev/null | fzf --preview 'head -100 {}')
    [ -n "$file" ] && echo "$file" | pbcopy && echo "Copied: $file"
}

# fv - fuzzy find file and open in nvim
fv() {
    local file
    file=$(find . -type f -not -path '*/.*' 2>/dev/null | fzf --preview 'head -100 {}')
    [ -n "$file" ] && nvim "$file"
}

# ff - fuzzy find and focus any aerospace window
ff() {
    aerospace list-windows --all | fzf --bind 'enter:execute(zsh -c "aerospace focus --window-id {1}")+abort'
}
