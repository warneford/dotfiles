return {
	{
		"quarto-dev/quarto-nvim",
		dependencies = {
			"jmbuhr/otter.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
		ft = { "quarto", "markdown" },
		config = function()
			local quarto = require("quarto")
			quarto.setup({
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
					default_method = "slime", -- using slime for simpler workflow
				},
			})

			-- Keybindings are defined in quarto-keybindings.lua
		end,
	},
	{
		"jmbuhr/otter.nvim",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
		},
		ft = { "quarto", "markdown" },
		opts = {
			buffers = {
				set_filetype = true,
			},
		},
		config = function()
			-- Automatically activate otter for code blocks in quarto files
			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "quarto", "markdown" },
				callback = function()
					require("otter").activate({ "r", "python", "julia", "bash" })
				end,
			})
		end,
	},
}
