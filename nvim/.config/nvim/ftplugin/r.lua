-- R-specific settings
-- This file is automatically loaded when opening .R files

-- Use treesitter for indentation (== operator)
vim.bo.indentexpr = "nvim_treesitter#indent()"

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
