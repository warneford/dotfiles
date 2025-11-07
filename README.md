# Dotfiles

My personal development environment configuration for quick setup on new machines.

## What's Included

### Neovim Configuration
Based on [ThePrimeagen's init.lua](https://github.com/ThePrimeagen/init.lua) configured for scientific computing workflows.

**Language Server Protocol (LSP) Support:**
- **Pyright** - Python language server
- **R Language Server** - R language server
- **TypeScript/JavaScript** - For data visualization and web-based notebooks
- **Lua** - For Neovim configuration

**Key Plugins:**
- **Harpoon2** - Quick file navigation
- **Leap.nvim** - Lightning-fast motion plugin
- **Telescope** - Fuzzy finder for files, text, and more
- **LSP** - Language Server Protocol support
- **Treesitter** - Advanced syntax highlighting
- **Fugitive** - Git integration
- **Undotree** - Visualize undo history
- **Trouble** - Pretty diagnostics list
- **Supermaven** - AI code completion
- **Conform** - Code formatting
- **Zenmode** - Distraction-free writing

### Zsh Configuration
- **Oh-My-Zsh** - Framework for managing zsh configuration
- **Powerlevel10k** - Beautiful and fast prompt theme
- **zsh-autosuggestions** - Command suggestions based on history
- **zsh-syntax-highlighting** - Syntax highlighting in terminal

## Quick Start

### Prerequisites
- Git
- Zsh
- A [Nerd Font](https://www.nerdfonts.com/) (for Powerlevel10k icons)

**Everything else is installed automatically - no root access required!**

The install script will automatically install:
- **macOS**: Dependencies via Homebrew (node, python, ripgrep, neovim)
- **Linux** (no root needed):
  - Rust (for building tools)
  - ripgrep (via cargo)
  - nvm + Node.js LTS (for LSP servers)
  - bob-nvim + neovim stable
  - Quarto CLI (latest version)
  - Python packages for plugins

### Installation

1. Clone this repository:
```bash
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

2. Run the installation script:
```bash
./install.sh
```

3. Restart your terminal or source your new zsh config:
```bash
source ~/.zshrc
```

4. Configure Powerlevel10k:
```bash
p10k configure
```

5. Open Neovim - plugins will install automatically:
```bash
nvim
```

## What the Install Script Does

### macOS (via Homebrew)
1. Installs dependencies: node, python, ripgrep, neovim, quarto

### Linux (no root required!)
1. Installs Rust toolchain
2. Installs ripgrep (via cargo)
3. Installs nvm (Node Version Manager)
4. Installs Node.js LTS (includes npm)
5. Installs bob-nvim (neovim version manager)
6. Installs neovim stable (via bob)
7. Installs Quarto CLI (auto-fetches latest version)

### Both Platforms
1. Installs oh-my-zsh, Powerlevel10k theme, zsh plugins
2. Backs up existing configs (`.zshrc`, nvim)
3. Creates symlinks for all dotfiles
4. Installs Python packages (pynvim, cairosvg, pillow)
5. Installs pipx and radian (enhanced R console)
6. Installs R languageserver package (if R is available)

## Key Bindings (Neovim)

### Harpoon
- `<leader>a` - Add file to harpoon
- `<leader>A` - Prepend file to harpoon
- `<C-e>` - Toggle harpoon menu
- `<C-h>`, `<C-t>`, `<C-n>`, `<C-s>` - Jump to harpoon files 1-4

### Leap
- `s{char}{char}` - Leap forward to {char}{char}
- `S{char}{char}` - Leap backward to {char}{char}

### General
See ThePrimeagen's config for additional keybindings in the individual plugin files.

## Customization

### Adding Your Own Plugins

Create a new file in `nvim/lua/theprimeagen/lazy/`:

```lua
return {
    "author/plugin-name",
    config = function()
        -- plugin configuration
    end,
}
```

### Modifying Zsh Config

Edit `zsh/.zshrc` to add your own aliases, paths, or configurations.

## Updating

To pull the latest changes:

```bash
cd ~/dotfiles
git pull
```

Then restart your terminal or run `source ~/.zshrc`.

For Neovim plugins, open nvim and run `:Lazy sync`.

## License

MIT
