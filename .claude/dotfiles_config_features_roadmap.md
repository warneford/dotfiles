# Features Roadmap

## R/quarto plugins / keybindings

- Fix indentation in R/quarto (perhaps with air upon :w)

## R/quarto

- modify Aerial to add shortcut to let me toggle execution of chunks
- quarto preview in mind-palace doesn't execute focus mode on orion
- research plugins to install all packages required for current notebook (i swear otter or nvim.r has this)
- add snippets to radian

## Lualine

- color lsp warnings red/yellow/green
- add yaml lsp and lua lsp
- refresh lualine format on save

## nvim

- snacks.indent scope highlight doesn't track cursor in R files (treesitter issue with R grammar)
- address checkhealth issues
- add popups for syntax suggestions with documentation snippets
- render hex color codes in markdown

## Keybindings/remapping

- change aerospace resizing from Alt+ -/+ to avoid conflict with nvim.r
- add functionality to ,l ,d bindings to send shell commands to terminal
- simplify terminal toggle keybinding
- organize keybindings logically (group by functionality and add to which-key)
