# Neovim Keybindings Cheat Sheet

## Essential Keys
- `<leader>` = `<Space>`
- `<localleader>` = `,` (rarely used now)
- Normal mode = default mode (press `Esc` to get here)
- Insert mode = typing mode (press `i` to enter)
- Visual mode = selection mode (press `v` to enter)

## Window Navigation
- `Ctrl+h` - Move to left window
- `Ctrl+j` - Move to window below
- `Ctrl+k` - Move to window above
- `Ctrl+l` - Move to right window

## Quarto Workflow

### Opening Terminals
- `<Space>cr` - Open R terminal (bottom split)
- `<Space>cp` - Open Python/IPython terminal (bottom split)
- `<Space>cj` - Open Julia terminal (bottom split)
- `<Space>cn` - Open shell terminal (bottom split)

### First Time Setup (per session)
1. Open your `.qmd` file
2. Press `<Space>cr` to open R terminal
3. Press `<Space>cs` to configure SLIME (just press Enter)
4. You're ready to run code!

### Running Code
- `<Space><Enter>` OR `Cmd+Enter` - Run code cell (cursor anywhere in code block)
- `<Enter>` (in visual mode) - Run selected lines
- `<Space>qrr` - Run from top to cursor
- `<Space>qra` - Run all cells
- `<Space>qrb` - Run from cursor to bottom

### Quarto Commands (`<Space>q`)
Press `<Space>q` and wait - which-key shows all options!
- `<Space>qa` - Activate Quarto
- `<Space>qp` - Preview document (opens browser)
- `<Space>qq` - Close preview
- `<Space>qh` - Quarto help
- `<Space>qm` - Toggle LaTeX math preview
- `<Space>qe` - Export code from Otter

### Insert Code Chunks (`<Space>o`)
- `<Space>or` - Insert R chunk
- `<Space>op` - Insert Python chunk
- `<Space>ob` - Insert Bash chunk
- `<Space>oj` - Insert Julia chunk

### SLIME Configuration
- `<Space>cm` - Mark terminal (see job ID)
- `<Space>cs` - Set terminal for SLIME

## File Navigation

### Harpoon (Quick File Switching)
- `<Space>a` - Add current file to harpoon
- `Ctrl+e` - Toggle harpoon menu
- `Ctrl+j` - Jump to file 1
- `Ctrl+k` - Jump to file 2
- `Ctrl+l` - Jump to file 3
- `Ctrl+;` - Jump to file 4

### Telescope (Fuzzy Finder)
- `<Space>pf` - Find files
- `<Space>ps` - Search in files (grep)
- `<Space><Space>` - Find buffers

### File Tree
- `<Space>e` - Toggle Neo-tree
- `<Space>o` - Focus Neo-tree

## Editing

### Clipboard
- `<Space>y` - Yank (copy) to system clipboard
- `<Space>Y` - Yank line to system clipboard
- `<Space>p` - Paste over selection without overwriting register

### Other
- `<Space>ii` - Paste image from clipboard (in Quarto/Markdown)
- `<Space>s` - Search and replace word under cursor
- `u` - Undo
- `Ctrl+r` - Redo

## LSP (Code Intelligence)
- `gd` - Go to definition
- `K` - Hover documentation
- `<Space>vca` - Code actions
- `<Space>vrr` - Find references
- `<Space>vrn` - Rename symbol

## Git
- `<Space>gs` - Git status (Fugitive)
- `:Git` - Open git commands

## Discover More Commands
Just press `<Space>` and wait a moment - **which-key** will show you all available commands organized by category!

## Tips
1. **Getting unstuck**: Press `Esc` a few times to get back to normal mode
2. **What mode am I in?**: Look at bottom left of screen
3. **Close a window**: `Ctrl+w` then `q` OR `:q<Enter>`
4. **Save file**: `:w<Enter>` or `Ctrl+s`
5. **Exit nvim**: `:q<Enter>` (or `:qa<Enter>` to quit all windows)

## Common Quarto Workflow
```
1. nvim myanalysis.qmd
2. <Space>cr                  # Open R terminal
3. <Space>cs                  # Configure SLIME (press Enter)
4. <Space>qp                  # Start preview in browser
5. Put cursor in code block
6. Cmd+Enter or <Space><Enter> # Run code!
7. <Space>qq                  # Close preview when done
```
