-- Additional keybindings for Quarto workflow
-- Loaded after quarto.nvim and vim-slime are set up

-- Global function for send_cell so it can be called from keybindings
-- Uses vim-slime's send_cell which relies on b:slime_cell_delimiter
-- After sending, moves cursor to the next code chunk
_G.send_cell = function()
	vim.fn["slime#send_cell"]()

	-- Move to the next code chunk (search for next ```)
	-- The 'W' flag means don't wrap around, 'c' means accept match at cursor
	local next_chunk = vim.fn.search("^```", "W")
	if next_chunk > 0 then
		-- Move one line down to get inside the chunk
		vim.cmd("normal! j")
	end
end

-- Send just the current line
_G.send_line = function()
	local line = vim.api.nvim_get_current_line()
	vim.fn["slime#send"](line .. "\r")
	-- Move to next line
	vim.cmd("normal! j")
end

-- View R object/dataframe in browser (like RStudio's View())
_G.view_r_object = function()
	-- Get the word under cursor (the variable name)
	local var = vim.fn.expand("<cword>")
	if var == "" then
		vim.notify("No variable under cursor", vim.log.levels.WARN)
		return
	end

	-- Send command to view in browser using DT::datatable or base View
	-- For dataframes, use DT for interactive viewing
	local cmd = string.format(
		'if (is.data.frame(%s)) { print(DT::datatable(%s)); browseURL(paste0("data:text/html,", htmltools::html_print(DT::datatable(%s)))) } else { print(%s) }',
		var,
		var,
		var,
		var
	)
	vim.fn["slime#send"](cmd .. "\r")
end

-- Show R environment variables (like RStudio's Environment pane)
_G.show_r_env = function()
	-- Show all objects in the environment with their type and size
	local cmd = [[
cat("\n=== R Environment ===\n")
if (length(ls()) == 0) {
  cat("No objects in environment\n")
} else {
  ls.str()
}
]]
	vim.fn["slime#send"](cmd .. "\r")
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

			-- Run single line
			vim.keymap.set("n", "<leader>l", _G.send_line, { desc = "run [l]ine" })
			vim.keymap.set("i", "<M-CR>", function()
				vim.cmd("stopinsert")
				_G.send_line()
			end, { desc = "run line from insert mode" })

			-- R-specific insert mode shortcuts
			vim.keymap.set("i", "<M-->", " <- ", { desc = "insert R assignment operator" })
			vim.keymap.set("i", "<M-m>", " |> ", { desc = "insert R pipe operator" })

			-- Insert code chunk with Ctrl+Shift+I (also provide Alt+i as fallback)
			vim.keymap.set("n", "<C-S-i>", function()
				local ft = vim.bo.filetype
				if ft == "quarto" or ft == "rmarkdown" or ft == "markdown" then
					-- Insert R code chunk by default
					vim.cmd("normal! o```{r}\r```")
					vim.cmd("normal! O")
					vim.cmd("startinsert")
				end
			end, { desc = "insert code chunk" })
			vim.keymap.set("i", "<C-S-i>", function()
				vim.cmd("stopinsert")
				local ft = vim.bo.filetype
				if ft == "quarto" or ft == "rmarkdown" or ft == "markdown" then
					vim.cmd("normal! o```{r}\r```")
					vim.cmd("normal! O")
					vim.cmd("startinsert")
				end
			end, { desc = "insert code chunk from insert mode" })
			-- Fallback for terminals that don't support Ctrl+Shift+I
			vim.keymap.set({ "n", "i" }, "<M-i>", function()
				if vim.fn.mode() == "i" then
					vim.cmd("stopinsert")
				end
				local ft = vim.bo.filetype
				if ft == "quarto" or ft == "rmarkdown" or ft == "markdown" then
					vim.cmd("normal! o```{r}\r```")
					vim.cmd("normal! O")
					vim.cmd("startinsert")
				end
			end, { desc = "insert code chunk (Alt+i)" })

			-- Run visual selection
			vim.keymap.set("v", "<CR>", ":<C-u>call slime#send_op(visualmode(), 1)<CR>", { desc = "run code region" })
			vim.keymap.set("v", "<S-CR>", ":<C-u>call slime#send_op(visualmode(), 1)<CR>", { desc = "run code region" })

			-- R object/variable viewing
			vim.keymap.set("n", "<leader>rv", _G.view_r_object, { desc = "[v]iew object/dataframe" })
			vim.keymap.set("n", "<leader>re", _G.show_r_env, { desc = "show [e]nvironment" })

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
