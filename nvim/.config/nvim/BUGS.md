# Neovim Plugin Bugs to Report

## snacks.nvim: `fg` nil error in gh/init.lua

**Status:** Related issue exists - [#2436](https://github.com/folke/snacks.nvim/issues/2436)
**Note:** Issue #2436 was fixed but the fix was incomplete - it only addressed `diff.lua`, not `gh/init.lua`
**Plugin:** [folke/snacks.nvim](https://github.com/folke/snacks.nvim)
**Version:** commit `fe7cfe9800a182274d0f868a74b7263b8c0c020b`
**Date discovered:** 2025-12-09

### Description

`:checkhealth snacks` crashes with error:

```
attempt to index local 'fg' (a nil value)
```

at `lua/snacks/util/init.lua:187` (the `blend()` function).

### Root Cause

In `lua/snacks/gh/init.lua:119-128`, the `diff_linenr()` function doesn't provide a fallback for `fg` when `Snacks.util.color()` returns `nil`:

```lua
local function diff_linenr(hl)
  local fg = Snacks.util.color({ hl, "SnacksGhNormalFloat", "Normal" })
  local bg = Snacks.util.color({ hl, "SnacksGhNormalFloat", "Normal" }, "bg")
  bg = bg or vim.o.background == "dark" and "#1e1e1e" or "#f5f5f5"
  -- fg has no fallback!
  return {
    fg = fg,
    bg = Snacks.util.blend(fg, bg, 0.1),  -- crashes when fg is nil
  }
end
```

The `blend()` function in `util/init.lua:185-192` calls `fg:sub()` which fails on nil.

### Fix

Add a fallback for `fg`, matching the pattern used in `lua/snacks/picker/util/diff.lua:40-41`:

```lua
local function diff_linenr(hl)
  local fg = Snacks.util.color({ hl, "SnacksGhNormalFloat", "Normal" })
  local bg = Snacks.util.color({ hl, "SnacksGhNormalFloat", "Normal" }, "bg")
  bg = bg or vim.o.background == "dark" and "#1e1e1e" or "#f5f5f5"
  fg = fg or vim.o.background == "dark" and "#f5f5f5" or "#1e1e1e"  -- ADD THIS LINE
  return {
    fg = fg,
    bg = Snacks.util.blend(fg, bg, 0.1),
  }
end
```

### Workaround

Manually edit `~/.local/share/nvim/lazy/snacks.nvim/lua/snacks/gh/init.lua` and add the fallback line. Note: This will be overwritten on plugin update.

### Environment

- Neovim: v0.10+ (latest stable)
- Terminal: Ghostty via SSH + tmux
- Colorscheme: catppuccin-mocha (transparent background)
- OS: Linux (Docker container)
