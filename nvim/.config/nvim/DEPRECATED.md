# Deprecated Plugins and Features

This document tracks plugins and features that have been deprecated or removed to prevent accidentally re-adding them.

## Removed Plugins

### cmp-r (R-nvim/cmp-r)
- **Removed**: 2025-12-02
- **Reason**: Deprecated by R.nvim maintainers. The message states: "Please, uninstall cmp-r. It's no longer used."
- **Alternative**: R.nvim now handles completions internally. Use the built-in R.nvim completion features instead.
- **Previous usage**: Was used for R completions and Quarto YAML frontmatter completion in nvim-cmp.

---

## Notes

When considering adding a new plugin, check this list first to ensure it hasn't been previously removed for good reason.
