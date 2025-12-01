return {
	"ggandor/leap.nvim",
	dependencies = { "tpope/vim-repeat" },
	config = function()
		local leap = require("leap")
		-- Set up default keymaps (s/S for forward/backward leap)
		vim.keymap.set({'n', 'x', 'o'}, 's',  '<Plug>(leap-forward)')
		vim.keymap.set({'n', 'x', 'o'}, 'S',  '<Plug>(leap-backward)')
		vim.keymap.set({'n', 'x', 'o'}, 'gs', '<Plug>(leap-from-window)')
	end,
}
