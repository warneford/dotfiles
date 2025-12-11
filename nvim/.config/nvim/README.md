# Neovim Config

### R/Quarto Development

This config includes LSP support for R and Quarto via otter.nvim and r-languageserver.

**File Navigation in R/Quarto:**
- `gd` (go to definition) works on `source()` and `here()` paths - the LSP is smart enough to resolve file paths inside R expressions like `source(here("path/to/file.R"))`
- This is more powerful than the built-in `gf` command, which only does simple path matching
