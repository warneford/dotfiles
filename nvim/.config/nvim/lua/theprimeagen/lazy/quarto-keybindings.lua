-- Additional keybindings for Quarto workflow
-- Loaded after quarto.nvim, R.nvim, and vim-slime are set up

-- Helper function to send code using vim-slime (works with any REPL: R, Python, Julia, etc.)
local function send_to_repl(code)
	-- vim-slime provides slime#send for sending text to tmux panes
	if vim.fn.exists("*slime#send") == 1 then
		vim.fn["slime#send"](code .. "\r")
	else
		vim.notify("vim-slime not loaded", vim.log.levels.WARN)
	end
end

-- Global function for send_cell - works with ANY language (R, Python, Julia)
-- Filters out comment lines before sending to REPL
-- After sending, moves cursor to the first line of the next code chunk
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

	-- Send the filtered code via vim-slime (works with R, Python, Julia, etc.)
	if #filtered_lines > 0 then
		local code = table.concat(filtered_lines, "\n")
		send_to_repl(code)
	end

	-- Move to the next code chunk (search for next ```)
	-- The 'W' flag means don't wrap around, 'c' means accept match at cursor
	local next_chunk = vim.fn.search("^```{", "W")
	if next_chunk > 0 then
		-- Move one line down to get to the first line inside the chunk
		vim.cmd("normal! j")
	end
end

-- Note: For R-specific functionality, use R.nvim's native keybindings:
-- ,rf - Start R console
-- ,ro - Object browser
-- ,rv - Dataframe viewer
-- ,d  - Send line/statement and move down
-- ,cc - Send current chunk
-- ,cd - Send chunk and move to next
--
-- This file provides language-agnostic Quarto keybindings that work with any REPL

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

			-- Note: <leader>l for sending lines/statements is now handled by R.nvim
			-- See rnvim.lua for R-specific keybindings

			-- R-specific insert mode shortcuts (these override R.nvim defaults for consistency)
			vim.keymap.set("i", "<M-->", " <- ", { desc = "insert R assignment operator", buffer = true })
			vim.keymap.set("i", "<M-m>", " |> ", { desc = "insert R pipe operator", buffer = true })

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

			-- Note: Visual selection sending is handled by R.nvim's <Plug>RSendSelection
			-- See rnvim.lua for configuration

			-- Note: R-specific keybindings are provided by R.nvim
			-- Use ,ro for object browser, ,rv for dataframe viewer, etc.

			-- Quarto rendering
			vim.keymap.set("n", "<leader>qp", function()
				local current_file = vim.fn.expand("%:p")
				if current_file:match("%.qmd$") or current_file:match("%.Rmd$") then
					-- Send quarto preview command to R console (tmux pane)
					-- Kill any existing process on port 9013 first, then start preview
					local cmd = "system('fuser -k 9013/tcp 2>/dev/null; quarto preview "
						.. current_file
						.. " --port 9013 --host 0.0.0.0 --no-browser')"
					require("r.send").cmd(cmd)
					vim.notify("Quarto preview sent to R console", vim.log.levels.INFO)
					-- Trigger Mac's quarto-preview function via reverse SSH tunnel (port 9014)
					-- Jump through tentacle to reach localhost:9014 (where RemoteForward listens)
					vim.fn.jobstart("ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -J dockerhost -p 9014 rwarne@localhost 'source ~/.zshrc && quarto-preview'", {
						detach = true,
						on_exit = function(_, code)
							if code ~= 0 then
								vim.schedule(function()
									vim.notify("Failed to open browser on Mac (exit " .. code .. ")", vim.log.levels.WARN)
								end)
							end
						end,
					})
				else
					vim.notify("Not a Quarto/RMarkdown file", vim.log.levels.WARN)
				end
			end, { desc = "[q]uarto [p]review in R console" })

			vim.keymap.set("n", "<leader>qP", function()
				local current_file = vim.fn.expand("%:p")
				if current_file:match("%.qmd$") or current_file:match("%.Rmd$") then
					-- Send quarto preview command with --cache-refresh to R console
					-- Kill any existing process on port 9013 first, then start preview
					local cmd = "system('fuser -k 9013/tcp 2>/dev/null; quarto preview "
						.. current_file
						.. " --cache-refresh --port 9013 --host 0.0.0.0 --no-browser')"
					require("r.send").cmd(cmd)
					vim.notify("Quarto preview (cache refresh) sent to R console", vim.log.levels.INFO)
				else
					vim.notify("Not a Quarto/RMarkdown file", vim.log.levels.WARN)
				end
			end, { desc = "[q]uarto [P]review with cache refresh" })

			vim.keymap.set("n", "<leader>qr", function()
				local current_file = vim.fn.expand("%:p")
				if current_file:match("%.qmd$") or current_file:match("%.Rmd$") then
					vim.notify("Rendering Quarto document...", vim.log.levels.INFO)
					vim.cmd("!" .. "quarto render " .. vim.fn.shellescape(current_file))
				else
					vim.notify("Not a Quarto/RMarkdown file", vim.log.levels.WARN)
				end
			end, { desc = "[q]uarto [r]ender (no preview)" })

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
