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
- Neovim (>= 0.9.0 recommended)
- Zsh
- A [Nerd Font](https://www.nerdfonts.com/) (for Powerlevel10k icons)

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

1. Installs oh-my-zsh (if not present)
2. Installs Powerlevel10k theme
3. Installs zsh plugins (autosuggestions, syntax-highlighting)
4. Backs up existing `.zshrc` and nvim config
5. Creates symlinks from `~/.zshrc` → `~/dotfiles/zsh/.zshrc`
6. Creates symlinks from `~/.config/nvim` → `~/dotfiles/nvim`

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
