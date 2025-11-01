# Tmux Quick Reference Guide

## Starting Tmux

```bash
tmux                      # Start new session
tmux new -s myproject     # Start named session
tmux ls                   # List sessions
tmux attach               # Attach to last session
tmux attach -t myproject  # Attach to specific session
tmux kill-session -t old  # Kill a session
```

## Key Bindings

**Prefix**: `Ctrl+Space` (press both, then release, then press command key)

### Panes (Splits)

| Key | Action |
|-----|--------|
| `Ctrl+Space` then `\|` | Split vertically (side by side) |
| `Ctrl+Space` then `-` | Split horizontally (top/bottom) |
| `Ctrl+h/j/k/l` | **Navigate panes/vim splits** (NO PREFIX!) |
| `Ctrl+Space` then `arrows` | Resize current pane |
| `Ctrl+Space` then `x` | Close current pane |
| `Ctrl+Space` then `z` | Zoom pane (fullscreen toggle) |

### Windows (Tabs)

| Key | Action |
|-----|--------|
| `Ctrl+Space` then `c` | Create new window |
| `Alt+1` to `Alt+5` | Jump to window 1-5 (NO PREFIX!) |
| `Alt+n` | Next window (NO PREFIX!) |
| `Alt+p` | Previous window (NO PREFIX!) |
| `Ctrl+Space` then `,` | Rename window |
| `Ctrl+Space` then `&` | Close window |
| `Ctrl+Space` then `<` | Move window left |
| `Ctrl+Space` then `>` | Move window right |

### Sessions

| Key | Action |
|-----|--------|
| `Ctrl+Space` then `d` | Detach (leave running) |
| `Ctrl+Space` then `$` | Rename session |
| `Ctrl+Space` then `(` | Previous session |
| `Ctrl+Space` then `)` | Next session |

### Other

| Key | Action |
|-----|--------|
| `Ctrl+Space` then `r` | Reload config |
| `Ctrl+Space` then `?` | Show all keybindings |
| Mouse | Click panes, resize, scroll |

## Workflow Examples

### Daily Use (Single Session)
```bash
# Start your main session once
tmux new -s work

# Work on different projects in different windows
Ctrl+Space c    # New window for project 1
Ctrl+Space c    # New window for project 2
Alt+1           # Jump to window 1
Alt+2           # Jump to window 2

# Split panes for code + terminal
Ctrl+Space |    # Split for code and R terminal
Ctrl+j          # Navigate to bottom pane
```

### Typical Quarto Workflow
```bash
tmux new -s quarto-work
nvim analysis.qmd       # Opens in top pane
Ctrl+Space -            # Split horizontally
# Now you have code on top, can run R below
```

### Why Use Tmux?

1. **Persistence**: Close terminal, come back later - everything's still there
2. **Organization**: Multiple windows for different tasks
3. **Flexibility**: Split screen any way you want
4. **Seamless nvim integration**: `Ctrl+hjkl` works across everything!

## Pro Tips

1. **Always use a named session**: `tmux new -s myproject`
   - Easy to remember and attach to

2. **One session is enough**: Use windows (tabs) for different projects

3. **Mouse is your friend**: Click to select panes, drag borders to resize

4. **Prefix + ?**: Shows ALL keybindings if you forget

5. **New panes open in same directory**: Super convenient!
