# Marimo-Quarto Integration Plan

## Overview

[quarto-marimo](https://github.com/marimo-team/quarto-marimo) embeds reactive Python notebooks (marimo islands) into Quarto documents. This enables interactive widgets that run in the browser via WebAssembly.

## Current Status

- **Tested in**: `~/projects/marimo_test/`
- **Working version combo**: marimo 0.13.x + quarto-marimo 0.4.3
- **Known issues**:
  - marimo 0.19.x breaks the extension (internal API changed - ModuleNotFoundError)
  - marimo 0.18.x UI widgets don't render (slider shows label but no widget)

## Project Setup Pattern

### 1. Directory Structure

```
project/
├── .envrc              # use_uv
├── .venv/              # created by direnv
├── _extensions/        # quarto-marimo extension
│   └── marimo-team/
├── pyproject.toml      # dependencies
├── uv.lock
└── *.qmd               # notebooks
```

### 2. pyproject.toml Template

```toml
[project]
name = "PROJECT_NAME"
version = "0.1.0"
requires-python = ">=3.10"

dependencies = [
    # Pin marimo for quarto-marimo 0.4.3 compatibility
    "marimo>=0.13.0,<0.14.0",
    # Add other deps as needed
    "pandas",
    "numpy",
]
```

### 3. QMD Frontmatter Template

```yaml
---
title: "Document Title"
format:
  html:
    code-fold: true  # doesn't affect marimo blocks
filters:
  - marimo
marimo:
  pyproject: |
    requires-python = ">=3.10"
    dependencies = [
      "numpy",
      "pandas",
    ]
---
```

**Note**: The `marimo.pyproject` dependencies are for the browser WASM runtime (loaded via micropip). Local venv deps are for build-time.

### 4. Code Block Options

```python
```{.marimo}
#| echo: true    # show code (editable in browser)
#| echo: false   # hide code (default)
#| eval: false   # don't execute
#| output: false # hide output
```
```

## Dotfiles Integration Options

### Option A: Shell Function (like uvinit)

Add to `zsh/functions.zsh`:

```zsh
# Initialize a marimo-quarto project
marimo-init() {
    local project_name="${1:-$(basename "$PWD")}"

    # Create .envrc
    echo "use_uv" > .envrc

    # Create pyproject.toml with marimo pinned
    cat > pyproject.toml << 'EOF'
[project]
name = "PROJECT_NAME"
version = "0.1.0"
requires-python = ">=3.10"

dependencies = [
    "marimo>=0.13.0,<0.14.0",
    "pandas",
    "numpy",
]
EOF
    sed -i "s/PROJECT_NAME/$project_name/" pyproject.toml

    # Add quarto extension
    quarto add marimo-team/quarto-marimo --no-prompt

    # Allow direnv
    direnv allow .

    echo "✓ Marimo-Quarto project initialized"
}
```

### Option B: Template Directory

Add to `templates/marimo-quarto/`:

```
templates/marimo-quarto/
├── .envrc
├── pyproject.toml
└── notebook.qmd        # starter template
```

### Option C: Neovim Snippet

Add marimo code block snippet for quarto files.

## Neovim Keybindings

### Proposed Additions to quarto-keybindings.lua

```lua
-- Insert marimo code chunk (Alt+m or <leader>im)
vim.keymap.set({ "n", "i" }, "<M-m>", function()
    if vim.fn.mode() == "i" then
        vim.cmd("stopinsert")
    end
    local ft = vim.bo.filetype
    if ft == "quarto" or ft == "markdown" then
        vim.cmd("normal! o```{.marimo}\n#| echo: true\n```")
        vim.cmd("normal! kO")
        vim.cmd("startinsert")
    end
end, { desc = "insert [m]arimo code chunk" })

-- Toggle echo on current marimo block
vim.keymap.set("n", "<leader>me", function()
    -- Find start of current marimo block
    local start_line = vim.fn.search("^```{.marimo}", "bnW")
    if start_line == 0 then
        vim.notify("Not in a marimo block", vim.log.levels.WARN)
        return
    end
    -- Check if #| echo: true exists on next line
    local next_line = vim.fn.getline(start_line + 1)
    if next_line:match("#| echo: true") then
        vim.fn.setline(start_line + 1, "#| echo: false")
    elseif next_line:match("#| echo: false") then
        vim.fn.setline(start_line + 1, "#| echo: true")
    else
        -- Insert echo option
        vim.fn.append(start_line, "#| echo: true")
    end
end, { desc = "[m]arimo toggle [e]cho" })
```

### Preview with Port (integrate with existing <leader>qp)

The existing `<leader>qp` in quarto-keybindings.lua already handles preview with port 9013. Marimo notebooks work with this.

## LSP Considerations

- **otter.nvim**: Already configured to handle Python in quarto files
- **Diagnostics**: Work inside `.marimo` blocks via otter
- **Completion**: Python completion works in marimo blocks

No changes needed to LSP config.

## Workflow Summary

1. **Create project**: `marimo-init myproject` (or use template)
2. **cd into project**: direnv auto-activates venv
3. **Add extension**: `quarto add marimo-team/quarto-marimo` (if not using init script)
4. **Write notebook**: Use `{.marimo}` blocks with `#| echo: true`
5. **Preview**: `<leader>qp` or `quarto preview file.qmd --port 9013`
6. **Iterate**: Code is editable in browser, reactively updates

## Known Limitations

1. **Version pinning**: Must use marimo <0.14.0 until extension is updated
2. **No native code-fold**: Quarto's `code-fold` doesn't work on marimo blocks
3. **Browser execution**: Heavy computation should stay in regular `{python}` blocks
4. **R integration**: R blocks stay static; marimo is Python-only

## Future Considerations

- Watch [quarto-marimo#43](https://github.com/marimo-team/quarto-marimo/issues/43) for extension overhaul
- Once updated, can use latest marimo and potentially better editor support
- Consider adding plotly/altair for interactive viz in marimo blocks

## Files to Modify

| File | Change |
|------|--------|
| `zsh/functions.zsh` | Add `marimo-init` function |
| `templates/marimo-quarto/` | Create template directory |
| `nvim/.config/nvim/lua/config/plugins/quarto-keybindings.lua` | Add marimo keybindings |

## Testing Checklist

- [ ] `marimo-init` creates working project
- [ ] direnv activates correctly
- [ ] `quarto preview` works
- [ ] Widgets are interactive in browser
- [ ] Code editing in browser triggers reactive updates (Ctrl+click)
- [ ] Neovim keybindings work
