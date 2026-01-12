# R Language Server Plugin for Claude Code

Provides R language intelligence via the R Language Server (languageserver R package).

## Features

- **Diagnostics**: See errors and warnings in R code immediately after edits
- **Code Navigation**: Go to definition, find references
- **Hover Information**: Type information and documentation for R functions
- **Rich Documentation**: Enhanced documentation display

## Requirements

The R language server must be installed. This plugin uses the Mason-installed version at:
```
~/.local/share/nvim/mason/bin/r-languageserver
```

If you need to install it manually:
```r
install.packages("languageserver")
```

## Supported File Types

- `.R`, `.r` - R scripts
- `.Rmd`, `.rmd` - R Markdown
- `.Rmarkdown`, `.rmarkdown` - R Markdown (alternative extension)
- `.qmd`, `.Qmd` - Quarto documents

## Installation

Install as a local plugin:
```bash
claude /plugin install /home/robert/dotfiles/claude-plugins/r-lsp
```

## Configuration

The plugin passes these settings to the language server:
- `rich_documentation: true` - Enhanced documentation display

Adjust `plugin.json` to customize settings.
