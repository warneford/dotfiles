local local_plugins = {
	-- Harpoon2 for file navigation
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local harpoon = require("harpoon")

			harpoon:setup()

			-- Add/manage files
			vim.keymap.set("n", "<leader>a", function()
				harpoon:list():add()
			end, { desc = "Harpoon: Add file" })

			vim.keymap.set("n", "<leader>h", function()
				harpoon.ui:toggle_quick_menu(harpoon:list())
			end, { desc = "Harpoon: Toggle menu" })

			-- Jump to files (QWERTY home row)
			vim.keymap.set("n", "<leader>j", function()
				harpoon:list():select(1)
			end, { desc = "Harpoon: File 1" })

			vim.keymap.set("n", "<leader>k", function()
				harpoon:list():select(2)
			end, { desc = "Harpoon: File 2" })

			vim.keymap.set("n", "<leader>l", function()
				harpoon:list():select(3)
			end, { desc = "Harpoon: File 3" })

			vim.keymap.set("n", "<leader>;", function()
				harpoon:list():select(4)
			end, { desc = "Harpoon: File 4" })

			-- Navigate through list
			vim.keymap.set("n", "<C-S-P>", function()
				harpoon:list():prev()
			end, { desc = "Harpoon: Previous file" })

			vim.keymap.set("n", "<C-S-N>", function()
				harpoon:list():next()
			end, { desc = "Harpoon: Next file" })
		end,
	},
}

return local_plugins
