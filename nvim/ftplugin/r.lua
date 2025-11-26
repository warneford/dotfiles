-- R-specific settings
-- This file is automatically loaded when opening .R files

-- Use treesitter for indentation (== operator)
vim.bo.indentexpr = "nvim_treesitter#indent()"

-- Alternative R start: vertical split (console below, 1/3 of screen)
-- Use <localleader>rb for vertical layout on smaller screens (bottom)
vim.keymap.set("n", "<localleader>rb", function()
	local config = require("r.config").get_config()
	-- Save and swap external_term
	local original = config.external_term
	config.external_term = "tmux split-window -v -l 15"
	-- Also need to reset the cached term_cmd in tmux module
	-- Easiest way: unload both modules so they reinitialize
	package.loaded["r.term.tmux"] = nil
	package.loaded["r.run"] = nil
	-- Now start R - it will reload modules with new config
	require("r.run").start_R("R")
	-- Restore after delay
	vim.defer_fn(function()
		config.external_term = original
	end, 500)
end, { buffer = true, desc = "Start R (bottom split, 1/3 screen)" })
