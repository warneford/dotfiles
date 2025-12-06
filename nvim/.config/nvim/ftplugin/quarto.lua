-- Quarto-specific settings
-- This file is automatically loaded when opening .qmd files

-- Tell vim-slime what defines a code cell (the ``` fence markers)
vim.b.slime_cell_delimiter = '```'

-- Wrap text by word, not character
vim.wo.wrap = true
vim.wo.linebreak = true
vim.wo.breakindent = true
vim.wo.showbreak = '|'

-- ,rb - Start R with bottom split layout (uses nvim terminal)
-- R.nvim now uses nvim's built-in terminal instead of tmux
-- The shell terminal opens automatically alongside R via toggleterm
vim.keymap.set("n", "<localleader>rb", function()
	-- Set R.nvim to use horizontal split (bottom 1/3 of screen)
	local config = require("r.config").get_config()
	config.rconsole_width = 0  -- 0 = horizontal split
	config.rconsole_height = math.floor(vim.o.lines / 3)
	require("r.run").start_R("R")
end, { buffer = true, desc = "Start R (bottom split)" })
