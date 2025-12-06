return {
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		config = function()
			require("toggleterm").setup({
				size = function(term)
					if term.direction == "horizontal" then
						return 15
					elseif term.direction == "vertical" then
						return vim.o.columns * 0.4
					end
				end,
				open_mapping = nil, -- We'll use custom mappings
				hide_numbers = true,
				shade_terminals = false,
				start_in_insert = true,
				insert_mappings = false,
				terminal_mappings = true,
				persist_size = true,
				persist_mode = true,
				direction = "horizontal",
				close_on_exit = true,
				shell = vim.o.shell,
				float_opts = {
					border = "curved",
					winblend = 0,
				},
			})

			local Terminal = require("toggleterm.terminal").Terminal

			-- Shell terminal (always available, count=2)
			-- Set NVIM_TERMINAL to skip MOTD display
			local shell_term = Terminal:new({
				cmd = "NVIM_TERMINAL=1 " .. vim.o.shell,
				count = 2,
				direction = "horizontal",
				display_name = "shell",
				on_open = function(term)
					vim.cmd("startinsert!")
					-- Set up terminal-mode mappings
					local opts = { buffer = term.bufnr, noremap = true, silent = true }
					vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
					vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
					vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
					vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
					vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], opts)
				end,
			})

			-- Python terminal (lazy, only created when needed, count=3)
			local python_term = nil

			local function get_python_term()
				if not python_term then
					python_term = Terminal:new({
						-- Use ipython-direnv wrapper to load project's Python environment
						cmd = "NVIM_TERMINAL=1 ipython-direnv",
						count = 3,
						direction = "horizontal",
						display_name = "python",
						on_open = function(term)
							vim.cmd("startinsert!")
							local opts = { buffer = term.bufnr, noremap = true, silent = true }
							vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
							vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
							vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
							vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
							vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], opts)
						end,
					})
				end
				return python_term
			end

			-- Helper to find R.nvim terminal window and buffer
			local function find_r_terminal()
				for _, buf in ipairs(vim.api.nvim_list_bufs()) do
					local bufname = vim.api.nvim_buf_get_name(buf)
					if bufname:match("term://.*[Rr]adian") or bufname:match("term://.*:R$") then
						-- Find window if visible
						for _, win in ipairs(vim.api.nvim_list_wins()) do
							if vim.api.nvim_win_get_buf(win) == buf then
								return buf, win
							end
						end
						return buf, nil
					end
				end
				return nil, nil
			end

			-- Toggle functions - swap between R and shell/python in same space
			local function toggle_shell()
				local r_buf, r_win = find_r_terminal()

				if shell_term:is_open() then
					-- Shell is open, close it and show R if available
					shell_term:close()
					if r_buf and not r_win then
						vim.cmd("botright split")
						vim.api.nvim_win_set_buf(0, r_buf)
						vim.cmd("resize " .. math.floor(vim.o.lines / 3))
					end
				else
					-- Shell is closed, hide R and open shell
					if r_win then
						vim.api.nvim_win_hide(r_win)
					end
					shell_term:open()
				end
			end

			local function toggle_python()
				local r_buf, r_win = find_r_terminal()
				local term = get_python_term()

				-- Check if python terminal window is actually visible
				local python_visible = term.bufnr and vim.api.nvim_buf_is_valid(term.bufnr)
					and vim.fn.bufwinnr(term.bufnr) ~= -1

				if python_visible then
					-- Python is visible, close it and show R if available
					term:close()
					if r_buf then
						vim.cmd("botright split")
						vim.api.nvim_win_set_buf(0, r_buf)
						vim.cmd("resize " .. math.floor(vim.o.lines / 3))
					end
				else
					-- Python is not visible, hide R and shell, open python
					if r_win then
						vim.api.nvim_win_hide(r_win)
					end
					if shell_term:is_open() then
						shell_term:close()
					end
					term:open()
				end
			end

			-- Send code to shell terminal
			local function send_to_shell(code)
				if not shell_term:is_open() then
					shell_term:open()
					-- Wait a bit for terminal to be ready
					vim.defer_fn(function()
						shell_term:send(code)
					end, 100)
				else
					shell_term:send(code)
				end
			end

			-- Send code to python terminal
			local function send_to_python(code)
				local term = get_python_term()
				if not term:is_open() then
					term:open()
					-- Wait a bit for ipython to start
					vim.defer_fn(function()
						term:send(code)
					end, 500)
				else
					term:send(code)
				end
			end

			-- Expose functions globally for use by other modules
			_G.toggleterm_shell = {
				toggle = toggle_shell,
				send = send_to_shell,
				term = shell_term,
			}

			_G.toggleterm_python = {
				toggle = toggle_python,
				send = send_to_python,
				get_term = get_python_term,
			}

			-- Open shell terminal alongside R when R starts
			-- This hooks into R.nvim's start event
			vim.api.nvim_create_autocmd("User", {
				pattern = "RStarted",
				callback = function()
					-- Small delay to let R terminal settle
					vim.defer_fn(function()
						if not shell_term:is_open() then
							shell_term:open()
							-- Return focus to editor
							vim.cmd("wincmd p")
						end
					end, 200)
				end,
			})

			-- Keybindings for terminal switching
			-- ,r2 - Toggle shell terminal
			vim.keymap.set("n", ",r2", toggle_shell, { desc = "Toggle shell terminal" })
			-- ,r3 - Toggle python terminal (lazy spawn)
			vim.keymap.set("n", ",r3", toggle_python, { desc = "Toggle python terminal" })

			-- Alternative: <C-\> based switching
			vim.keymap.set("n", "<C-\\>2", toggle_shell, { desc = "Toggle shell terminal" })
			vim.keymap.set("n", "<C-\\>3", toggle_python, { desc = "Toggle python terminal" })

			-- Quick toggle for shell (most common use case)
			vim.keymap.set("n", "<leader>ts", toggle_shell, { desc = "[t]oggle [s]hell terminal" })
			vim.keymap.set("n", "<leader>tp", toggle_python, { desc = "[t]oggle [p]ython terminal" })

			-- Terminal select (pick from list)
			vim.keymap.set("n", "<leader>tt", "<cmd>TermSelect<cr>", { desc = "[t]erminal select" })
		end,
	},
}
