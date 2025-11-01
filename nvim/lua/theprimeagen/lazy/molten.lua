return {
	{
		"benlubas/molten-nvim",
		version = "^1.0.0", -- use version <2.0.0 to avoid breaking changes
		dependencies = { "3rd/image.nvim" },
		build = ":UpdateRemotePlugins",
		init = function()
			-- Configuration options
			vim.g.molten_image_provider = "image.nvim"
			vim.g.molten_output_win_max_height = 20
			vim.g.molten_auto_open_output = true
			vim.g.molten_wrap_output = true
			vim.g.molten_virt_text_output = true
			vim.g.molten_virt_lines_off_by_1 = true
		end,
		config = function()
			-- Keybindings for Molten
			vim.keymap.set("n", "<localleader>mi", ":MoltenInit<CR>", { desc = "Molten: Initialize kernel", silent = true })
			vim.keymap.set("n", "<localleader>me", ":MoltenEvaluateOperator<CR>", { desc = "Molten: Evaluate operator", silent = true })
			vim.keymap.set("n", "<localleader>ml", ":MoltenEvaluateLine<CR>", { desc = "Molten: Evaluate line", silent = true })
			vim.keymap.set("n", "<localleader>mr", ":MoltenReevaluateCell<CR>", { desc = "Molten: Re-evaluate cell", silent = true })
			vim.keymap.set("v", "<localleader>mv", ":<C-u>MoltenEvaluateVisual<CR>gv", { desc = "Molten: Evaluate visual selection", silent = true })
			vim.keymap.set("n", "<localleader>md", ":MoltenDelete<CR>", { desc = "Molten: Delete cell", silent = true })
			vim.keymap.set("n", "<localleader>mo", ":MoltenShowOutput<CR>", { desc = "Molten: Show output", silent = true })
			vim.keymap.set("n", "<localleader>mh", ":MoltenHideOutput<CR>", { desc = "Molten: Hide output", silent = true })

			-- Quarto integration - run code cell
			vim.keymap.set("n", "<localleader><CR>", ":MoltenEvaluateOperator<CR>", { desc = "Run code cell", silent = true })
			vim.keymap.set("v", "<localleader><CR>", ":<C-u>MoltenEvaluateVisual<CR>gv", { desc = "Run visual selection", silent = true })
		end,
	},
	{
		"3rd/image.nvim",
		opts = {
			backend = "kitty", -- or "ueberzug" for most terminals
			integrations = {
				markdown = {
					enabled = true,
					clear_in_insert_mode = false,
					download_remote_images = true,
					only_render_image_at_cursor = false,
					filetypes = { "markdown", "vimwiki", "quarto" },
				},
			},
			max_width = 100,
			max_height = 12,
			max_height_window_percentage = math.huge,
			max_width_window_percentage = math.huge,
			window_overlap_clear_enabled = true,
			window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
		},
	},
}
