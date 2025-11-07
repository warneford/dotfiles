-- Additional keybindings for Quarto workflow
-- Loaded after quarto.nvim and vim-slime are set up

-- Global function for send_cell so it can be called from keybindings
-- Filters out comment lines before sending to REPL
-- After sending, moves cursor to the first line of the next code chunk
-- If not in a code chunk, just moves to the next chunk
_G.send_cell = function()
	local current_line = vim.fn.line(".")

	-- Find the start of the current code cell (search backwards for ```)
	local start_line = vim.fn.search("^```{", "bnW")

	-- If not inside a code chunk, just move to the next chunk
	if start_line == 0 then
		local next_chunk = vim.fn.search("^```{", "W")
		if next_chunk > 0 then
			vim.cmd("normal! j")
		else
			vim.notify("No more code chunks below", vim.log.levels.INFO)
		end
		return
	end

	-- Find the end of the current code cell (search forwards for ```)
	local end_line = vim.fn.search("^```$", "nW")
	if end_line == 0 then
		vim.notify("Could not find end of code chunk", vim.log.levels.WARN)
		return
	end

	-- Get all lines in the cell (excluding the ``` delimiters)
	local lines = vim.api.nvim_buf_get_lines(0, start_line, end_line - 1, false)

	-- Filter out comment lines (lines that start with # after whitespace)
	local filtered_lines = {}
	for _, line in ipairs(lines) do
		-- Keep line if it's not purely a comment (allow inline comments)
		if not line:match("^%s*#") then
			table.insert(filtered_lines, line)
		end
	end

	-- Send the filtered code to slime
	if #filtered_lines > 0 then
		local code = table.concat(filtered_lines, "\n")
		vim.fn["slime#send"](code .. "\r")
	end

	-- Move to the next code chunk (search for next ```)
	-- The 'W' flag means don't wrap around, 'c' means accept match at cursor
	local next_chunk = vim.fn.search("^```{", "W")
	if next_chunk > 0 then
		-- Move one line down to get to the first line inside the chunk
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

-- View R object/dataframe (multiple options)
_G.view_r_object = function()
	-- Get the word under cursor (the variable name)
	local var = vim.fn.expand("<cword>")
	if var == "" then
		vim.notify("No variable under cursor", vim.log.levels.WARN)
		return
	end

	-- Display in console with nice formatting using tibble's print or head
	local cmd = string.format(
		'if (is.data.frame(%s)) { cat("\\n"); print(%s); cat("\\nDimensions:", nrow(%s), "rows x", ncol(%s), "columns\\n") } else { print(%s) }',
		var,
		var,
		var,
		var,
		var
	)
	vim.fn["slime#send"](cmd .. "\r")
end

-- View R object in browser (for when you want the full interactive table)
_G.view_r_object_browser = function()
	local var = vim.fn.expand("<cword>")
	if var == "" then
		vim.notify("No variable under cursor", vim.log.levels.WARN)
		return
	end

	-- Open in default browser with DT for interactive viewing
	local cmd = string.format(
		'if (is.data.frame(%s)) { DT::datatable(%s) } else { print(%s) }',
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

-- Load YAML params into R environment (like RStudio does)
_G.load_quarto_params = function()
	local current_file = vim.fn.expand("%:p")

	-- Check if current file is a .qmd or .Rmd file
	if not (current_file:match("%.qmd$") or current_file:match("%.Rmd$")) then
		vim.notify("Not a Quarto/RMarkdown file", vim.log.levels.WARN)
		return
	end

	-- Use knitr::knit_params() to extract params from YAML header
	-- Then extract the values into a params list (like RStudio does)
	local cmd = string.format(
		[[
params_list <- tryCatch({
  p <- knitr::knit_params('%s')
  if (length(p) > 0) {
    # Extract values from param objects
    params <- lapply(p, function(x) x$value)
    names(params) <- sapply(p, function(x) x$name)
    cat("\nLoaded params:\n")
    str(params)
    cat("\n")
    params
  } else {
    cat("No params defined in YAML header\n")
    list()
  }
}, error = function(e) {
  cat("Error reading params:", e$message, "\n")
  list()
})
params <- params_list
rm(params_list)
]],
		current_file:gsub("\\", "\\\\"):gsub("'", "\\'")
	)

	vim.fn["slime#send"](cmd .. "\r")
	vim.notify("Params loaded from YAML", vim.log.levels.INFO)
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
			vim.keymap.set("n", "<leader>rp", _G.load_quarto_params, { desc = "load [p]arams from YAML" })

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
