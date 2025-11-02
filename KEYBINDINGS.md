# Neovim + Quarto + R IDE Keybindings

Complete reference for your custom Neovim-based R development environment.

## Leader Keys
- **Leader**: `Space`
- **Local Leader**: `,`

---

## Code Execution (Quarto/R)

### Running Code
| Keybinding | Mode | Description |
|------------|------|-------------|
| `<Space><Enter>` | Normal | Run current code chunk, move to next chunk |
| `<Ctrl+Enter>` | Normal/Insert | Run current code chunk |
| `<Shift+Enter>` | Normal/Insert | Run current code chunk (may not work in all terminals) |
| `<Space>l` | Normal | Run current line, move to next line |
| `<Alt+Enter>` | Insert | Run current line from insert mode |
| `<Enter>` | Visual | Run selected code region |
| `<Shift+Enter>` | Visual | Run selected code region |

### Quarto Commands
| Keybinding | Mode | Description |
|------------|------|-------------|
| `<Space>qa` | Normal | Activate Quarto |
| `<Space>qp` | Normal | Preview Quarto document |
| `<Space>qq` | Normal | Close Quarto preview |
| `<Space>qh` | Normal | Quarto help |
| `<Space>qe` | Normal | Export with otter |
| `<Space>qE` | Normal | Export with overwrite |
| `<Space>qrr` | Normal | Run code from start to cursor |
| `<Space>qra` | Normal | Run all code |
| `<Space>qrb` | Normal | Run code from cursor to end |
| `<Space>qm` | Normal | Toggle math equation preview |

---

## R-Specific Features

### R Operators & Shortcuts
| Keybinding | Mode | Description |
|------------|------|-------------|
| `<Alt+->` | Insert | Insert ` <- ` (assignment operator) |
| `<Alt+m>` | Insert | Insert ` \|> ` (pipe operator) |

### Code Chunks
| Keybinding | Mode | Description |
|------------|------|-------------|
| `<Ctrl+Shift+i>` | Normal/Insert | Insert new R code chunk |
| `<Alt+i>` | Normal/Insert | Insert new R code chunk (fallback) |
| `<Space>or` | Normal | Insert R code chunk template |
| `<Space>op` | Normal | Insert Python code chunk template |
| `<Space>ob` | Normal | Insert Bash code chunk template |
| `<Space>oj` | Normal | Insert Julia code chunk template |

### R Object/Environment Inspection
| Keybinding | Mode | Description |
|------------|------|-------------|
| `<Space>rv` | Normal | View dataframe/object under cursor in browser |
| `<Space>re` | Normal | Show R environment variables |
| `K` | Normal | Show function documentation/help |
| `<Ctrl+h>` | Insert | Show function signature help |

---

## Terminal Management

### Opening Terminals
| Keybinding | Mode | Description |
|------------|------|-------------|
| `<Space>cr` | Normal | Open new R terminal (10 lines) |
| `<Space>cp` | Normal | Open new Python/IPython terminal |
| `<Space>cj` | Normal | Open new Julia terminal |
| `<Space>cn` | Normal | Open new shell terminal |

### Terminal Configuration
| Keybinding | Mode | Description |
|------------|------|-------------|
| `<Space>cm` | Normal | Mark current terminal |
| `<Space>cs` | Normal | Set/configure slime terminal target |

### Terminal Mode Navigation
| Keybinding | Mode | Description |
|------------|------|-------------|
| `jk` | Terminal | Exit terminal mode to normal mode |
| `<Esc><Esc>` | Terminal | Exit terminal mode to normal mode |
| `<Ctrl+\><Ctrl+n>` | Terminal | Exit terminal mode (default) |

---

## Window & Pane Navigation

### Vim/Tmux Seamless Navigation
| Keybinding | Mode | Description |
|------------|------|-------------|
| `<Ctrl+h>` | Normal | Navigate to left pane (vim/tmux) |
| `<Ctrl+j>` | Normal | Navigate to down pane (vim/tmux) |
| `<Ctrl+k>` | Normal | Navigate to up pane (vim/tmux) |
| `<Ctrl+l>` | Normal | Navigate to right pane (vim/tmux) |

### Vim Window Resizing
| Keybinding | Mode | Description |
|------------|------|-------------|
| `<Ctrl+w>+` | Normal | Increase window height |
| `<Ctrl+w>-` | Normal | Decrease window height |
| `<Ctrl+w>_` | Normal | Maximize window height |
| `<Ctrl+w>=` | Normal | Equalize all window sizes |
| `:resize 10` | Command | Set window to 10 lines tall |

---

## Tmux Keybindings

**Note**: Tmux prefix is `<Ctrl+Space>`

### Window Management
| Keybinding | Description |
|------------|-------------|
| `<Ctrl+Space>c` | Create new window |
| `<Ctrl+Space>\|` | Split vertically |
| `<Ctrl+Space>-` | Split horizontally |
| `<Alt+n>` | Next window |
| `<Alt+p>` | Previous window |
| `<Alt+1>` through `<Alt+5>` | Jump to window 1-5 |

### Pane Management
| Keybinding | Description |
|------------|-------------|
| `<Ctrl+h/j/k/l>` | Navigate between panes (vim-aware) |
| `<Ctrl+Space>!` | Break pane into new window |
| `<Ctrl+Space>:join-pane -t 2` | Move pane to window 2 |
| `<Ctrl+Space>:choose-tree` | Interactive pane/window selection |

### Pane Resizing
| Keybinding | Description |
|------------|-------------|
| `<Ctrl+Space><Left>` | Resize pane left |
| `<Ctrl+Space><Right>` | Resize pane right |
| `<Ctrl+Space><Up>` | Resize pane up |
| `<Ctrl+Space><Down>` | Resize pane down |

### Tmux Utilities
| Keybinding | Description |
|------------|-------------|
| `<Ctrl+Space>r` | Reload tmux config |
| `<Ctrl+Space>[` | Enter copy mode (scroll mode) |
| Mouse scroll | Scroll in tmux (auto copy mode) |
| Mouse drag | Resize panes |

---

## LSP (Language Server Protocol)

### Code Navigation
| Keybinding | Mode | Description |
|------------|------|-------------|
| `gd` | Normal | Go to definition |
| `K` | Normal | Show hover documentation (press `K` again to enter popup) |
| `<Space>vws` | Normal | Workspace symbol search |
| `<Space>vd` | Normal | Show diagnostics in float |
| `<Space>vca` | Normal | Code actions |
| `<Space>vrr` | Normal | Find references |
| `<Space>vrn` | Normal | Rename symbol |
| `[d` | Normal | Go to next diagnostic |
| `]d` | Normal | Go to previous diagnostic |

---

## Otter (Language Features in Code Chunks)

| Keybinding | Mode | Description |
|------------|------|-------------|
| `<Space>oa` | Normal | Activate otter |
| `<Space>od` | Normal | Deactivate otter |
| `<Space>os` | Normal | Show otter symbols |

---

## File & Project Navigation

### Telescope (Fuzzy Finder)
| Keybinding | Mode | Description |
|------------|------|-------------|
| `<Space>pf` | Normal | Find files |
| `<Ctrl+p>` | Normal | Git files |
| `<Space>ps` | Normal | Grep string |

### File Explorer
| Keybinding | Mode | Description |
|------------|------|-------------|
| `<Space>pv` | Normal | Open file explorer (netrw) |
| `<Space>e` | Normal | Toggle Neo-tree |

---

## Editing & Text Manipulation

### Clipboard Operations
| Keybinding | Mode | Description |
|------------|------|-------------|
| `<Space>y` | Normal/Visual | Yank to system clipboard |
| `<Space>Y` | Normal | Yank line to system clipboard |
| `<Space>p` | Visual | Paste without overwriting register |
| `<Space>d` | Normal/Visual | Delete without overwriting register |

### Line Movement
| Keybinding | Mode | Description |
|------------|------|-------------|
| `J` | Visual | Move selected lines down |
| `K` | Visual | Move selected lines up |
| `J` | Normal | Join line below to current line |

### Search & Replace
| Keybinding | Mode | Description |
|------------|------|-------------|
| `<Space>s` | Normal | Search/replace word under cursor |
| `n` | Normal | Next search result (centered) |
| `N` | Normal | Previous search result (centered) |
| `<Ctrl+d>` | Normal | Half page down (centered) |
| `<Ctrl+u>` | Normal | Half page up (centered) |

---

## Utilities

### General
| Keybinding | Mode | Description |
|------------|------|-------------|
| `<Space><Space>` | Normal | Reload vim config (or source current lua file) |
| `<Space>u` | Normal | Open undo tree |
| `<Space>x` | Normal | Make file executable |

### Git (Fugitive)
| Keybinding | Mode | Description |
|------------|------|-------------|
| `<Space>gs` | Normal | Git status |

---

## Special Features

### Image Insertion
| Keybinding | Mode | Description |
|------------|------|-------------|
| `<Space>ii` | Normal | Insert image from clipboard |

### Zen Mode
| Keybinding | Mode | Description |
|------------|------|-------------|
| `<Space>zz` | Normal | Toggle zen mode (distraction-free) |

---

## Configuration Files Location

- **Neovim config**: `~/.config/nvim/` or `/Users/rwarne/dotfiles/nvim/`
- **Tmux config**: `/Users/rwarne/dotfiles/tmux/.tmux.conf`
- **Zsh config**: `/Users/rwarne/dotfiles/zsh/.zshrc`

---

## Quick Reference: Common Workflows

### Starting an R Analysis Session
1. `nvim analysis.qmd` - Open your Quarto document
2. `<Space>cr` - Open R console (10 lines at bottom)
3. `<Space>cs` - Configure slime (press Enter to accept default)
4. `<Space>qa` - Activate Quarto (auto-activates otter for LSP)
5. `<Space>qp` - Preview rendered document in browser
6. Start coding and use `<Space><Enter>` to run chunks!

### Inspecting Data & Objects
1. Position cursor on dataframe/variable name
2. `<Space>rv` - View dataframe in browser (interactive table)
3. `K` - Show function documentation
4. `<Space>re` - List all environment variables
5. `gd` - Jump to where variable was defined

### Efficient Code Development
1. `<Alt+i>` - Insert new R code chunk
2. Type code using:
   - `<Alt+->` for `<-` (assignment)
   - `<Alt+m>` for `|>` (pipe)
3. `<Space>l` - Run current line (step through code)
4. `<Space><Enter>` - Run entire chunk when ready
5. Visual select lines + `<Enter>` - Run specific selection

### Working with Multiple Files
1. `<Space>pf` - Find and open files
2. `<Ctrl+p>` - Quickly switch between git-tracked files
3. `<Space>ps` - Search for text across all files
4. `gd` - Jump to function definitions in other files

---

## Dependencies

### R Packages (for full functionality)
```r
install.packages("DT")              # For interactive dataframe viewing
install.packages("htmltools")       # For HTML output
install.packages("languageserver")  # For LSP support (autocomplete, go-to-def)
```

### Terminal Configuration (iTerm2)

**For Shift+Enter and Ctrl+Enter:**
1. iTerm2 Preferences (`Cmd+,`)
2. Profiles → Keys → Key Mappings
3. Click `+` to add:
   - `Shift+Enter` → Send Escape Sequence → `[13;2u`
   - `Ctrl+Enter` → Send Escape Sequence → `[13;5u`

**For Alt/Option keys:**
1. Preferences → Profiles → Keys → General
2. Set "Left Option key" to "Esc+" or "Meta"

---

## Tips & Tricks

### Navigation
1. **Scrolling in tmux**: Use mouse wheel or `<Ctrl+Space>[` to enter copy mode
2. **LSP popup windows**: Press `K` twice to enter popup, navigate with `j/k`, exit with `q`
3. **Terminal resize**: Use `:resize 10` or drag the split border with mouse
4. **Quick window jumps**: `<Ctrl+w>w` cycles through windows

### Productivity
1. **Config reload**: `<Space><Space>` works from any buffer
2. **Getting help**: Use `K` on any R function for instant documentation
3. **Discover commands**: Press `<Space>` and wait - which-key shows all options
4. **Getting unstuck**: Press `<Esc>` several times to return to normal mode

### Working with Chunks
1. **Run chunk and advance**: `<Space><Enter>` automatically moves to next chunk
2. **Run partial analysis**: Use `<Space>qrr` to run everything up to cursor
3. **Iterative development**: Use `<Space>l` to step through line by line
4. **Quick chunk insertion**: `<Alt+i>` works in both normal and insert mode

### Data Inspection
1. **Quick peek**: Hover over variable and press `K` to see its structure
2. **Interactive viewing**: `<Space>rv` on a dataframe opens DT::datatable in browser
3. **Environment overview**: `<Space>re` shows all objects and their types
4. **Console output**: Press `<Ctrl+j>` to jump to R console and see results

---

## Troubleshooting

### Code Not Running?
1. Make sure R terminal is open (`<Space>cr`)
2. Configure slime target (`<Space>cs`)
3. Activate Quarto (`<Space>qa`)
4. Check you're inside a code chunk (between ` ```{r} ` fences)

### LSP Not Working?
1. Check R languageserver is installed: `install.packages("languageserver")`
2. Activate otter: `<Space>oa`
3. Restart Neovim

### Keybinding Not Working?
1. Check terminal configuration (iTerm2 settings for special keys)
2. Try the fallback version (e.g., `<Alt+i>` instead of `<Ctrl+Shift+i>`)
3. Reload config: `<Space><Space>`

### Terminal Mode Stuck?
1. Press `jk` or `<Esc><Esc>` to exit terminal mode
2. Then use `<Ctrl+h/j/k/l>` to navigate away

---

## Learning Resources

- **Which-key**: Press `<Space>` and wait to discover commands
- **Help in Neovim**: `:help <topic>` (e.g., `:help telescope`)
- **R Documentation**: Position cursor on function and press `K`
- **This file**: Keep it open in a split for quick reference!
