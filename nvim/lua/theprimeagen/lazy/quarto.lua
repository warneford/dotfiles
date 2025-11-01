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
			vim.keymap.set("n", "<localleader>qp", function()
				vim.cmd("!quarto preview " .. vim.fn.expand("%") .. " &")
			end, { desc = "Quarto: Preview document" })
			vim.keymap.set("n", "<localleader>qr", function()
				vim.cmd("!quarto render " .. vim.fn.expand("%"))
			end, { desc = "Quarto: Render document" })
			vim.keymap.set("n", "<localleader>qq", function()
				vim.cmd("!pkill -f 'quarto preview'")
			end, { desc = "Quarto: Close preview" })
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
