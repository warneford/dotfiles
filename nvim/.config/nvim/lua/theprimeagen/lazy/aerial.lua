return {
	"stevearc/aerial.nvim",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		require("aerial").setup({
			-- Attach to any buffer with supported filetype
			attach_mode = "global",

			-- Show line numbers in aerial window
			show_guides = true,

			-- Position of aerial window (right side like RStudio)
			layout = {
				default_direction = "prefer_right",
				placement = "edge",
			},

			-- Automatically open aerial when opening supported files
			open_automatic = false, -- Set to true if you want it always open

			-- Filter what shows in the outline
			filter_kind = {
				"Class",
				"Constructor",
				"Enum",
				"Function",
				"Interface",
				"Module",
				"Method",
				"Struct",
				-- For markdown/quarto files
				"Namespace", -- Shows as headings in markdown
			},

			-- Enable for these filetypes
			-- aerial uses treesitter and LSP to get symbols
			treesitter = {
				enabled = true,
			},

			-- Markdown-specific: show all heading levels
			markdown = {
				-- Show all heading levels (# ## ### etc)
				update_events = "TextChanged,InsertLeave",
			},
		})

		-- Keybindings
		vim.keymap.set("n", "<leader>o", "<cmd>AerialToggle!<CR>", { desc = "[o]utline toggle" })
		vim.keymap.set("n", "<leader>oo", "<cmd>AerialOpen<CR>", { desc = "[o]utline [o]pen" })
		vim.keymap.set("n", "<leader>oc", "<cmd>AerialClose<CR>", { desc = "[o]utline [c]lose" })
		vim.keymap.set("n", "[s", "<cmd>AerialPrev<CR>", { desc = "Previous symbol" })
		vim.keymap.set("n", "]s", "<cmd>AerialNext<CR>", { desc = "Next symbol" })
		vim.keymap.set("n", "[[", "<cmd>AerialPrevUp<CR>", { desc = "Previous symbol (up level)" })
		vim.keymap.set("n", "]]", "<cmd>AerialNextUp<CR>", { desc = "Next symbol (up level)" })
	end,
}
