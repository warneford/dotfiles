local local_plugins = {
	-- Harpoon2 for file navigation
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local harpoon = require("harpoon")

			harpoon:setup()

			-- Refresh lualine after harpoon navigation
			local function refresh_lualine()
				vim.schedule(function()
					pcall(function()
						require("lualine").setup()
						vim.api.nvim_set_hl(0, "lualine_c_winbar", { bg = "none" })
						vim.api.nvim_set_hl(0, "lualine_c_winbar_inactive", { bg = "none" })
					end)
				end)
			end

			-- Add/manage files
			vim.keymap.set("n", "<leader>a", function()
				harpoon:list():add()
			end, { desc = "Harpoon: Add file" })

			vim.keymap.set("n", "<C-e>", function()
				harpoon.ui:toggle_quick_menu(harpoon:list())
			end, { desc = "Harpoon: Toggle menu" })

			-- Jump to files (leader + number)
			vim.keymap.set("n", "<leader>1", function()
				harpoon:list():select(1)
				refresh_lualine()
			end, { desc = "Harpoon: File 1" })

			vim.keymap.set("n", "<leader>2", function()
				harpoon:list():select(2)
				refresh_lualine()
			end, { desc = "Harpoon: File 2" })

			vim.keymap.set("n", "<leader>3", function()
				harpoon:list():select(3)
				refresh_lualine()
			end, { desc = "Harpoon: File 3" })

			vim.keymap.set("n", "<leader>4", function()
				harpoon:list():select(4)
				refresh_lualine()
			end, { desc = "Harpoon: File 4" })

			-- Navigate through list
			vim.keymap.set("n", "<C-S-P>", function()
				harpoon:list():prev()
				refresh_lualine()
			end, { desc = "Harpoon: Previous file" })

			vim.keymap.set("n", "<C-S-N>", function()
				harpoon:list():next()
				refresh_lualine()
			end, { desc = "Harpoon: Next file" })
		end,
	},
}

return local_plugins
