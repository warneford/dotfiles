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

			-- Keybindings for Quarto (using <leader>q prefix)
			vim.keymap.set("n", "<leader>qa", ":QuartoActivate<CR>", { desc = "[a]ctivate", silent = true })
			vim.keymap.set("n", "<leader>qp", function()
				quarto.quartoPreview()
			end, { desc = "[p]review" })
			vim.keymap.set("n", "<leader>qq", function()
				quarto.quartoClosePreview()
			end, { desc = "[q]uit preview" })
			vim.keymap.set("n", "<leader>qh", ":QuartoHelp ", { desc = "[h]elp" })
			vim.keymap.set("n", "<leader>qe", function()
				require("otter").export()
			end, { desc = "[e]xport" })
			vim.keymap.set("n", "<leader>qE", function()
				require("otter").export(true)
			end, { desc = "[E]xport with overwrite" })

			-- Run commands
			vim.keymap.set("n", "<leader>qrr", ":QuartoSendAbove<CR>", { desc = "to cu[r]sor" })
			vim.keymap.set("n", "<leader>qra", ":QuartoSendAll<CR>", { desc = "run [a]ll" })
			vim.keymap.set("n", "<leader>qrb", ":QuartoSendBelow<CR>", { desc = "run [b]elow" })

			-- Helper functions for code chunks
			local function insert_code_chunk(lang)
				vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<esc>", true, false, true), "n", true)
				local keys = "o```{" .. lang .. "}\r```<esc>O"
				keys = vim.api.nvim_replace_termcodes(keys, true, false, true)
				vim.api.nvim_feedkeys(keys, "n", false)
			end

			vim.keymap.set("n", "<leader>or", function()
				insert_code_chunk("r")
			end, { desc = "[r] code chunk" })
			vim.keymap.set("n", "<leader>op", function()
				insert_code_chunk("python")
			end, { desc = "[p]ython code chunk" })
			vim.keymap.set("n", "<leader>ob", function()
				insert_code_chunk("bash")
			end, { desc = "[b]ash code chunk" })
			vim.keymap.set("n", "<leader>oj", function()
				insert_code_chunk("julia")
			end, { desc = "[j]ulia code chunk" })
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
