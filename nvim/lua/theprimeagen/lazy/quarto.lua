return {
	{
		"quarto-dev/quarto-nvim",
		dependencies = {
			"jmbuhr/otter.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
		ft = { "quarto", "markdown" },
		config = function()
			require("quarto").setup({
				lspFeatures = {
					enabled = true,
					languages = { "r", "python", "julia", "bash" },
					chunks = "curly", -- 'curly' or 'all'
					diagnostics = {
						enabled = true,
						triggers = { "BufWritePost" },
					},
					completion = {
						enabled = true,
					},
				},
				codeRunner = {
					enabled = true,
					default_method = "molten", -- 'molten' or 'slime'
				},
			})

			-- Keybindings for Quarto
			local quarto = require("quarto")
			vim.keymap.set("n", "<localleader>qp", quarto.quartoPreview, { desc = "Quarto: Preview document" })
			vim.keymap.set("n", "<localleader>qq", quarto.quartoClosePreview, { desc = "Quarto: Close preview" })
			vim.keymap.set("n", "<localleader>qh", ":QuartoHelp ", { desc = "Quarto: Help" })
			vim.keymap.set("n", "<localleader>qe", ":QuartoExport ", { desc = "Quarto: Export" })
		end,
	},
	{
		"jmbuhr/otter.nvim",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
		},
		opts = {},
	},
}
