-- Quarto-specific settings
-- This file is automatically loaded when opening .qmd files

-- Tell vim-slime what defines a code cell (the ``` fence markers)
vim.b.slime_cell_delimiter = '```'

-- Wrap text by word, not character
vim.wo.wrap = true
vim.wo.linebreak = true
vim.wo.breakindent = true
vim.wo.showbreak = '|'

-- Alternative R start: vertical split (console below)
-- Use <localleader>rb for vertical layout on smaller screens (bottom)
vim.keymap.set("n", "<localleader>rb", function()
	local config = require("r.config").get_config()
	local original = config.external_term
	config.external_term = "tmux split-window -v -l 15"
	package.loaded["r.term.tmux"] = nil
	package.loaded["r.run"] = nil
	require("r.run").start_R("R")
	vim.defer_fn(function()
		config.external_term = original
	end, 500)
end, { buffer = true, desc = "Start R (bottom split)" })
