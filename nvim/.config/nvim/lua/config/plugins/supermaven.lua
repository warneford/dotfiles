return {
	{
		"supermaven-inc/supermaven-nvim",
		lazy = false,
		priority = 1100, -- Load before colorscheme so autocmds register first
		config = function()
			require("supermaven-nvim").setup({
				keymaps = {
					accept_suggestion = "<Tab>",
					clear_suggestion = "<C-]>",
					accept_word = "<C-j>",
				},
				ignore_filetypes = { cpp = true },
				color = {
					suggestion_color = "#7ab0b8",
					cterm = 244,
				},
				log_level = "info",
				disable_inline_completion = false,
				disable_keymaps = false,
				condition = function()
					return false
				end,
			})

			-- Re-set highlight on ColorScheme (triggered by colorizer on BufEnter)
			vim.api.nvim_create_autocmd("ColorScheme", {
				callback = function()
					vim.api.nvim_set_hl(0, "SupermavenSuggestion", { fg = "#7ab0b8", ctermfg = 244 })
				end,
			})
		end,
	},
}
