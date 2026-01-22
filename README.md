# Dotfiles

My personal development environment—a terminal descent through aesthetics and scientific computing workflows. After all, what you do is almost as important as how you look doing it. Built for quick setup on new machines and tested across macOS and Linux (no root required).

## The Premise

This is an opinionated environment for **R/Quarto data science work** with excellent Python support. Where possible, the tools try to integrate well with each other: Neovim sends code to tmux panes running radian, vim keybindings work seamlessly across splits and panes, and macOS software integrates with terminal/CLI tools.

## What's Included

| Component                              | Purpose              | Highlights                                            |
| -------------------------------------- | -------------------- | ----------------------------------------------------- |
| **[Neovim](#neovim)**                  | Primary editor       | LSP, Quarto, R integration, AI completion             |
| **[Zsh](#zsh)**                        | Shell                | Oh-My-Zsh, Powerlevel10k, custom functions            |
| **[Tmux](#tmux)**                      | Terminal multiplexer | Vim-tmux navigation, sensible defaults                |
| **[Ghostty](#ghostty)**                | Terminal emulator    | 30+ custom shaders, because why not                   |
| **[direnv + uv](#python-environment)** | Python environment   | Automatic venv activation, fast dependency management |
| **[R + radian](#r-environment)**       | R development        | Per-project radian, reticulate-compatible Python      |
| **[Docker](#docker-optional)**         | Containerized R dev  | Reproducible environment for the commitment-phobic    |

### macOS Extras

| Component      | Purpose                                     |
| -------------- | ------------------------------------------- |
| **AeroSpace**  | i3-like tiling window manager               |
| **SketchyBar** | Custom status bar with workspace indicators |
| **Karabiner**  | Advanced keyboard remapping                 |
| **Borders**    | Window border highlighting (JankyBorders)   |

## Quick Start

### Prerequisites

- Git
- Zsh
- A [Nerd Font](https://www.nerdfonts.com/) (for icons—I recommend Fira Code)

**Everything else installs automatically.** No root access required on Linux.

### Installation

```bash
git clone https://github.com/warneford/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

Restart your terminal, then:

```bash
p10k configure  # Set up your prompt
nvim            # Plugins install automatically
```

### What Gets Installed

**macOS** (via Homebrew):

- node, python, ripgrep, neovim, lazygit, tmux, quarto, and friends

**Linux** (no root needed):

- Rust toolchain → ripgrep (cargo)
- nvm → Node.js LTS
- bob-nvim → Neovim stable
- Quarto CLI (latest)
- lazygit

**Both platforms**:

- Oh-My-Zsh + Powerlevel10k + plugins
- Python packages (pynvim, cairosvg, pillow)
- R languageserver (if R is available)

---

## The Components

### Neovim

Based on [ThePrimeagen's init.lua](https://github.com/ThePrimeagen/init.lua), heavily customized for scientific computing.

**LSP Support**: Pyright (Python), R Language Server, TypeScript, Lua, Bash

**Key Plugins**:

- **Quarto/R**: quarto-nvim, nvim-r, slime (REPL integration via tmux)
- **Navigation**: Harpoon, Telescope, Leap
- **Code**: Treesitter, LSP, Conform (formatting), Trouble (diagnostics)
- **Quality of Life**: Supermaven (AI completion), Undotree, Zenmode
- **Extras**: img-clip (paste images), nabla (LaTeX preview), DAP (debugging)

### Zsh

- **Framework**: Oh-My-Zsh
- **Theme**: Powerlevel10k (fast, beautiful, highly configurable)
- **Plugins**: git, zsh-autosuggestions, zsh-syntax-highlighting

**Custom additions**:

- `uvinit` - Initialize a project with direnv + uv
- `quarto-preview` - Preview with proper browser handling
- Dynamic ASCII art MOTD (because terminals should spark joy)

### Tmux

Prefix: `Ctrl+Space` (ergonomic, doesn't conflict with vim)

**Features**:

- **Vim-tmux-navigator**: `Ctrl+hjkl` moves between vim splits AND tmux panes seamlessly
- **Sensible window switching**: `Alt+1-5` for windows, `Alt+n/p` for next/prev
- **True color**: 24-bit RGB, undercurl, italics
- **Smart navigation**: Avoids interfering with radian/Claude Code processes
- **Mouse support**: Because sometimes you just want to click

See **[TMUX_GUIDE.md](TMUX_GUIDE.md)** for the full reference.

### Ghostty

The terminal of choice. Config includes:

- **30+ custom GLSL shaders**: Bloom, starfield, matrix, CRT, galaxy, dither effects
- Shaders range from "subtle and readable" to "I am become terminal, destroyer of eyestrain"
- Background images for extra atmosphere

### Python Environment

**direnv + uv** for automatic, fast virtual environments:

```bash
cd my-project
uvinit           # Creates .envrc + pyproject.toml, syncs deps
# direnv auto-activates venv whenever you cd into the directory
```

The `use_uv` function in direnvrc handles everything—respects `.python-version`, syncs from `pyproject.toml` or `requirements.txt`.

### R Environment

#### Why radian and ipython are per-project

**radian** (enhanced R console) and **ipython** (enhanced Python REPL) are intentionally installed per-project rather than globally. This ensures reticulate uses the same Python environment as your project dependencies—critical for reproducible R↔Python workflows in polyglot Quarto notebooks.

#### Getting started with R

```bash
mkdir my-analysis && cd my-analysis
uvinit                    # Creates .envrc + pyproject.toml (includes radian + ipython!)
                          # Opens pyproject.toml in nvim
                          # Edit dependencies, :wq to save and sync
r                         # Alias for radian - now available in this directory
```

The default `pyproject.toml` template includes both radian and ipython, so every project gets them automatically.

#### radian features

Once installed in your project:

- Vi mode editing (matching nvim muscle memory)
- `Alt+-` inserts `<-` (assignment)
- `Alt+m` inserts `|>` (pipe)
- Syntax highlighting, multiline editing, 20k line history

#### ipython features

For Python chunks in Quarto notebooks:

- Syntax highlighting, tab completion, `?` for help
- `%magic` commands, better tracebacks
- Handles multi-line code blocks from nvim seamlessly
- Same Python environment as your R/reticulate code

#### .Rprofile

Global R configuration includes:

- Posit Package Manager (fast binary packages) with CRAN fallback
- Google auth for gargle/googledrive packages

> **Escape hatch**: For quick one-off R sessions where reticulate compatibility doesn't matter, you _can_ run `uv tool install radian` to get a global radian. Just understand it won't see your project's Python packages.

### Docker (Optional)

A containerized R development environment for when you want reproducibility without commitment:

```bash
# Coming soon: ./install.sh --docker
```

**r-dev container** includes:

- rocker/r-ver base (minimal R, no RStudio overhead)
- Neovim (latest), Node.js, deno, ripgrep, fzf, direnv
- Your dotfiles mounted and ready
- Quarto preview (port 9013), SSH (9015)

### macOS Window Management

**AeroSpace**: i3-like tiling for macOS

- Workspaces 1-9 with keyboard navigation
- Accordion and tile layouts
- Focus-follows-mouse on monitor change

**SketchyBar**: Status bar with:

- Workspace indicators
- System monitoring (CPU, calendar)
- GitHub notifications
- Zen mode toggle

**Karabiner**: Complex key remapping (separate config)

**Borders**: Subtle window highlighting via JankyBorders

---

## Documentation

- **[KEYBINDINGS.md](KEYBINDINGS.md)** - Comprehensive keybinding reference _(TODO: some conflicts to resolve)_
- **[TMUX_GUIDE.md](TMUX_GUIDE.md)** - Tmux quick reference and workflows

## Customization

### Adding Neovim Plugins

Create a file in `nvim/.config/nvim/lua/theprimeagen/lazy/`:

```lua
return {
    "author/plugin-name",
    config = function()
        -- your config here
    end,
}
```

### Modifying Zsh

- **Aliases**: `zsh/aliases.zsh`
- **Functions**: `zsh/functions.zsh`
- **Main config**: `zsh/.zshrc`

### Stow Structure

This repo uses [GNU Stow](https://www.gnu.org/software/stow/) for symlink management. Each directory contains the config structure as it should appear from `$HOME`:

```
dotfiles/
├── nvim/.config/nvim/     → ~/.config/nvim/
├── tmux/.tmux.conf        → ~/.tmux.conf
├── zsh/.zshrc             → ~/.zshrc
└── ...
```

## Updating

```bash
cd ~/dotfiles
git pull
source ~/.zshrc  # or restart terminal
```

For Neovim plugins: `:Lazy sync`
