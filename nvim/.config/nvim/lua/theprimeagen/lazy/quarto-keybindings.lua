-- Additional keybindings for Quarto workflow
-- Loaded after quarto.nvim, R.nvim, and toggleterm are set up

-- Helper function to detect current chunk language using otter.nvim
local function get_current_chunk_language()
	local ok, otter_fn = pcall(require, "otter.tools.functions")
	if not ok then
		return nil
	end

	-- Check each language otter knows about
	if otter_fn.is_otter_language_context("r") then
		return "r"
	elseif otter_fn.is_otter_language_context("bash") then
		return "bash"
	elseif otter_fn.is_otter_language_context("sh") then
		return "bash"
	elseif otter_fn.is_otter_language_context("python") then
		return "python"
	elseif otter_fn.is_otter_language_context("julia") then
		return "julia"
	end

	return nil
end

-- Context-aware code sending - routes to appropriate terminal based on language
local function send_code_to_repl(code, lang)
	if lang == "r" or lang == nil then
		-- Use R.nvim's native sender (nil = outside chunk, default to R)
		local ok, r_send = pcall(require, "r.send")
		if ok then
			local send_ok, err = pcall(r_send.cmd, code)
			if not send_ok then
				vim.notify("Failed to send to R. Is R running? Start with ,rf", vim.log.levels.WARN)
			end
		else
			vim.notify("R.nvim not available", vim.log.levels.WARN)
		end
	elseif lang == "bash" or lang == "sh" then
		-- Use toggleterm shell
		if _G.toggleterm_shell then
			_G.toggleterm_shell.send(code)
		else
			vim.notify("Shell terminal not available. Press ,r2 to open.", vim.log.levels.WARN)
		end
	elseif lang == "python" then
		-- Use toggleterm python (lazy spawn)
		if _G.toggleterm_python then
			_G.toggleterm_python.send(code)
		else
			vim.notify("Python terminal not available. Press ,r3 to open.", vim.log.levels.WARN)
		end
	end
end

-- Get current line text
local function get_current_line()
	return vim.api.nvim_get_current_line()
end

-- Get visual selection text
local function get_visual_selection()
	local start_pos = vim.fn.getpos("'<")
	local end_pos = vim.fn.getpos("'>")
	local lines = vim.api.nvim_buf_get_lines(0, start_pos[2] - 1, end_pos[2], false)
	if #lines == 0 then
		return ""
	end
	-- Handle partial line selection
	if #lines == 1 then
		lines[1] = lines[1]:sub(start_pos[3], end_pos[3])
	else
		lines[1] = lines[1]:sub(start_pos[3])
		lines[#lines] = lines[#lines]:sub(1, end_pos[3])
	end
	return table.concat(lines, "\n")
end

-- Helper to safely call R.nvim lua functions
local function call_rnvim(fn_path, ...)
	local args = {...}
	local ok, result = pcall(function()
		local parts = vim.split(fn_path, "%.")
		local mod_path = table.concat(vim.list_slice(parts, 1, #parts - 1), ".")
		local fn_name = parts[#parts]
		local mod = require(mod_path)
		return mod[fn_name](unpack(args))
	end)
	if not ok then
		vim.notify("R.nvim not ready. Is R running? Start with ,rf", vim.log.levels.WARN)
	end
	return ok
end

-- Context-aware wrapper: send line and move down (like ,d)
local function send_line_down()
	local lang = get_current_chunk_language()
	if lang == "r" or lang == nil then
		-- Use R.nvim's native function (preserves parenblock behavior)
		call_rnvim("r.send.line", "move")
	else
		-- Send current line to appropriate terminal
		local line = get_current_line()
		send_code_to_repl(line, lang)
		-- Move down
		vim.cmd("normal! j")
	end
end

-- Context-aware wrapper: send line, stay (like ,l)
local function send_line_stay()
	local lang = get_current_chunk_language()
	if lang == "r" or lang == nil then
		call_rnvim("r.send.line", "stay")
	else
		local line = get_current_line()
		send_code_to_repl(line, lang)
	end
end

-- Context-aware wrapper: send chunk and move (like ,cd)
local function send_chunk_down()
	local lang = get_current_chunk_language()
	if lang == "r" or lang == nil then
		-- Use r.rmd for quarto/rmd files
		call_rnvim("r.rmd.send_current_chunk", true)
	else
		-- Use our send_cell which already handles chunks
		_G.send_cell()
	end
end

-- Context-aware wrapper: send chunk, stay (like ,cc)
local function send_chunk_stay()
	local lang = get_current_chunk_language()
	if lang == "r" or lang == nil then
		call_rnvim("r.rmd.send_current_chunk", false)
	else
		-- Send chunk but don't move
		local start_line = vim.fn.search("^```{", "bnW")
		if start_line == 0 then
			vim.notify("Not inside a code chunk", vim.log.levels.WARN)
			return
		end
		local end_line = vim.fn.search("^```$", "nW")
		if end_line == 0 then
			vim.notify("Could not find end of code chunk", vim.log.levels.WARN)
			return
		end
		local lines = vim.api.nvim_buf_get_lines(0, start_line, end_line - 1, false)
		local code = table.concat(lines, "\n")
		send_code_to_repl(code, lang)
	end
end

-- Context-aware wrapper: send visual selection
local function send_selection()
	local lang = get_current_chunk_language()
	if lang == "r" or lang == nil then
		call_rnvim("r.send.selection")
	else
		local selection = get_visual_selection()
		send_code_to_repl(selection, lang)
	end
end

-- Expose wrapper functions globally for keybinding setup
_G.context_send = {
	line_down = send_line_down,
	line_stay = send_line_stay,
	chunk_down = send_chunk_down,
	chunk_stay = send_chunk_stay,
	selection = send_selection,
}

-- Global function for send_cell - context-aware routing based on chunk language
-- Filters out comment lines before sending to REPL
-- After sending, moves cursor to the first line of the next code chunk
_G.send_cell = function()
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

	-- Get the language from otter
	local lang = get_current_chunk_language()

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

	-- Send the filtered code to the appropriate REPL
	if #filtered_lines > 0 then
		local code = table.concat(filtered_lines, "\n")
		send_code_to_repl(code, lang)
	end

	-- Move to the next code chunk (search for next ```)
	-- The 'W' flag means don't wrap around, 'c' means accept match at cursor
	local next_chunk = vim.fn.search("^```{", "W")
	if next_chunk > 0 then
		-- Move one line down to get to the first line inside the chunk
		vim.cmd("normal! j")
	end
end

-- Context-aware keybindings that wrap R.nvim commands
-- These use the same keybindings as R.nvim but route to the appropriate terminal
-- based on the current chunk language (R, bash, python, etc.)
--
-- Keybindings (with LocalLeader = ,):
-- ,d  - Send line/statement and move down (context-aware)
-- ,l  - Send line/statement, stay (context-aware)
-- ,cc - Send chunk, stay (context-aware)
-- ,cd - Send chunk and move (context-aware)
-- ,ss - Send selection (context-aware)
--
-- R-specific commands still work as before:
-- ,rf - Start R console
-- ,rq - Quit R
-- ,ro - Object browser
-- ,rv - View dataframe

return {
	{
		"quarto-dev/quarto-nvim",
		optional = true,
		config = function()
			-- Override R.nvim keybindings with context-aware versions for quarto files
			-- This runs after R.nvim loads, so we override its mappings
			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "quarto", "rmarkdown", "markdown" },
				callback = function(args)
					local opts = { buffer = args.buf, noremap = true, silent = true }

					-- Context-aware send line and move down (like ,d)
					vim.keymap.set("n", ",d", _G.context_send.line_down, vim.tbl_extend("force", opts, { desc = "Send line/statement, move down" }))

					-- Context-aware send line, stay (like ,l)
					vim.keymap.set("n", ",l", _G.context_send.line_stay, vim.tbl_extend("force", opts, { desc = "Send line/statement, stay" }))

					-- Context-aware send chunk and move (like ,cd)
					vim.keymap.set("n", ",cd", _G.context_send.chunk_down, vim.tbl_extend("force", opts, { desc = "Send chunk, move to next" }))

					-- Context-aware send chunk, stay (like ,cc)
					vim.keymap.set("n", ",cc", _G.context_send.chunk_stay, vim.tbl_extend("force", opts, { desc = "Send chunk, stay" }))

					-- Context-aware send selection (like ,ss)
					vim.keymap.set("x", ",ss", _G.context_send.selection, vim.tbl_extend("force", opts, { desc = "Send selection" }))
				end,
			})

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

			-- R-specific insert mode shortcuts
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
					-- Send quarto preview command to shell terminal (keeps R console free)
					-- Kill any existing process on port 9013 first, then start preview
					local cmd = "fuser -k 9013/tcp 2>/dev/null; quarto preview "
						.. current_file
						.. " --port 9013 --host 0.0.0.0 --no-browser"

					if _G.toggleterm_shell then
						_G.toggleterm_shell.send(cmd)
						vim.notify("Quarto preview sent to shell terminal", vim.log.levels.INFO)
					else
						vim.notify("Shell terminal not available. Press ,r2 to open.", vim.log.levels.WARN)
						return
					end

					-- Only trigger reverse SSH tunnel if running inside a Docker container
					local is_docker = vim.fn.filereadable("/.dockerenv") == 1
					if is_docker then
						-- Wait for quarto preview to start (poll for port 9013)
						-- Then trigger local machine's browser via reverse SSH tunnel
						local local_user_env = vim.fn.getenv("LOCAL_USER")
						local local_user = (local_user_env ~= vim.NIL and local_user_env) or "rwarne"
						local attempts = 0
						local max_attempts = 180 -- 3 minutes max wait
						local timer = vim.loop.new_timer()
						timer:start(
							1000,
							1000,
							vim.schedule_wrap(function()
								attempts = attempts + 1
								-- Check if port 9013 is listening
								local handle = io.popen("fuser 9013/tcp 2>/dev/null")
								local result = handle:read("*a")
								handle:close()
								if result and result ~= "" then
									-- Port is ready, trigger browser
									timer:stop()
									timer:close()
									vim.fn.jobstart(
										"ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o 'ProxyCommand=ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -W %h:%p dockerhost' -p 9014 "
											.. local_user
											.. "@localhost 'source ~/.zshrc && quarto-preview'",
										{
											detach = true,
											on_exit = function(_, code)
												if code ~= 0 then
													vim.schedule(function()
														vim.notify(
															"Failed to open browser on Mac (exit " .. code .. ")",
															vim.log.levels.WARN
														)
													end)
												end
											end,
										}
									)
								elseif attempts >= max_attempts then
									timer:stop()
									timer:close()
									vim.notify("Timeout waiting for quarto preview to start", vim.log.levels.WARN)
								end
							end)
						)
					end
				else
					vim.notify("Not a Quarto/RMarkdown file", vim.log.levels.WARN)
				end
			end, { desc = "[q]uarto [p]review in shell terminal" })

			vim.keymap.set("n", "<leader>qP", function()
				local current_file = vim.fn.expand("%:p")
				if current_file:match("%.qmd$") or current_file:match("%.Rmd$") then
					-- Send quarto preview command with --cache-refresh to shell terminal
					-- Kill any existing process on port 9013 first, then start preview
					local cmd = "fuser -k 9013/tcp 2>/dev/null; quarto preview "
						.. current_file
						.. " --cache-refresh --port 9013 --host 0.0.0.0 --no-browser"

					if _G.toggleterm_shell then
						_G.toggleterm_shell.send(cmd)
						vim.notify("Quarto preview (cache refresh) sent to shell terminal", vim.log.levels.INFO)
					else
						vim.notify("Shell terminal not available. Press ,r2 to open.", vim.log.levels.WARN)
					end
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
