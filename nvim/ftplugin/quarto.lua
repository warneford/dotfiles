-- Quarto-specific settings
-- This file is automatically loaded when opening .qmd files

-- Tell vim-slime what defines a code cell (the ``` fence markers)
vim.b.slime_cell_delimiter = '```'

-- Wrap text by word, not character
vim.wo.wrap = true
vim.wo.linebreak = true
vim.wo.breakindent = true
vim.wo.showbreak = '|'
