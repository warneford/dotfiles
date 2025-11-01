-- Additional keybindings for Quarto workflow
-- Loaded after quarto.nvim and vim-slime are set up

-- Global function for send_cell so it can be called from keybindings
-- Uses vim-slime's send_cell which relies on b:slime_cell_delimiter
_G.send_cell = function()
	vim.fn["slime#send_cell"]()
end

return {
	{
		"quarto-dev/quarto-nvim",
		optional = true,
		config = function()
			-- Run code cell with <leader><CR> (space + enter) or Ctrl+Enter
			vim.keymap.set("n", "<leader><CR>", _G.send_cell, { desc = "run code cell" })
			vim.keymap.set("n", "<C-CR>", _G.send_cell, { desc = "run code cell" }) -- Ctrl+Enter
			vim.keymap.set("n", "<S-CR>", _G.send_cell, { desc = "run code cell" }) -- Shift+Enter (may not work in all terminals)
			vim.keymap.set("i", "<C-CR>", function()
				vim.cmd("stopinsert")
				_G.send_cell()
			end, { desc = "run code cell from insert mode" })
			vim.keymap.set("i", "<S-CR>", function()
				vim.cmd("stopinsert")
				_G.send_cell()
			end, { desc = "run code cell from insert mode" })

			-- Run visual selection
			vim.keymap.set("v", "<CR>", ":<C-u>call slime#send_op(visualmode(), 1)<CR>", { desc = "run code region" })
			vim.keymap.set("v", "<S-CR>", ":<C-u>call slime#send_op(visualmode(), 1)<CR>", { desc = "run code region" })

			-- Otter keybindings
			vim.keymap.set("n", "<leader>oa", function()
				require("otter").activate()
			end, { desc = "otter [a]ctivate" })
			vim.keymap.set("n", "<leader>od", function()
				require("otter").deactivate()
			end, { desc = "otter [d]eactivate" })
			vim.keymap.set("n", "<leader>os", function()
				require("otter.keeper").export()
			end, { desc = "otter [s]ymbols" })
		end,
	},
}
