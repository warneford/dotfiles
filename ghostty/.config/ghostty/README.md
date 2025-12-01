# Ghostty Terminal Configuration

Modern, GPU-accelerated terminal with text-based configuration.

## Features

- **Theme:** Rose Pine Moon (matches Neovim color scheme)
- **Font:** JetBrainsMono Nerd Font
- **Background:** Custom image with 80% opacity
- **Cursor:** Block style with blink effect and visual feedback on jumps
- **Quarto Integration:** Shift+Enter and Ctrl+Enter configured for code execution
- **R Workflow:** Alt/Option key configured as Meta for R operators

## Installation

1. Install Ghostty:
   ```bash
   brew install --cask ghostty
   ```

2. Symlink configuration:
   ```bash
   mkdir -p ~/.config/ghostty
   ln -sf ~/dotfiles/ghostty/config ~/.config/ghostty/config
   ```

3. Restart Ghostty to apply changes

## Key Mappings

All your existing keybindings from the Neovim/Quarto setup will work:

- **Shift+Enter** / **Ctrl+Enter** - Run code cells in Quarto
- **Alt+-** - Insert R assignment operator `<-`
- **Alt+m** - Insert R pipe operator `|>`
- **Alt+i** - Insert code chunk

## Customization

### Change Background Image
Edit `config` and update:
```
background-image = /path/to/your/image.jpg
background-opacity = 0.8
```

### Adjust Font Size
```
font-size = 14  # Change to preferred size
```

### Disable Cursor Blink
```
cursor-style-blink = false
```

### Theme Colors
Current theme is Rose Pine Moon. To customize, modify the `palette` entries in the config file.

## Troubleshooting

**Config not loading?**
- Check symlink: `ls -la ~/.config/ghostty/config`
- Restart Ghostty completely (Cmd+Q and reopen)
- Check for syntax errors: Ghostty will show error messages on startup

**Keybindings not working?**
- Verify `macos-option-as-alt = true` is set
- Check that keybinds are in format: `keybind = key=text:\x1b[code]`
- Restart Ghostty after config changes

**Background image not showing?**
- Verify image path is absolute (starts with `/`)
- Check image file exists: `ls ~/horses_art_night_129683_1680x1050.jpg`
- Supported formats: JPG, PNG

## Resources

- [Ghostty Documentation](https://ghostty.org/docs)
- [Rose Pine Theme](https://rosepinetheme.com/)
- [Nerd Fonts](https://www.nerdfonts.com/)
