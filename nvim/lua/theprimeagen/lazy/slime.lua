return {
	{
		"jpalardy/vim-slime",
		init = function()
			vim.b["quarto_is_python_chunk"] = false
			Quarto_is_in_python_chunk = function()
				require("otter.tools.functions").is_otter_language_context("python")
			end

			-- Configure SLIME to work with IPython and R
			vim.cmd([[
			let g:slime_dispatch_ipython_pause = 100
			function SlimeOverride_EscapeText_quarto(text)
			call v:lua.Quarto_is_in_python_chunk()
			if exists('g:slime_python_ipython') && len(split(a:text,"\n")) > 1 && b:quarto_is_python_chunk && !(exists('b:quarto_is_r_mode') && b:quarto_is_r_mode)
			return ["%cpaste -q\n", g:slime_dispatch_ipython_pause, a:text, "--", "\n"]
			else
			if exists('b:quarto_is_r_mode') && b:quarto_is_r_mode && b:quarto_is_python_chunk
			return [a:text, "\n"]
			else
			return [a:text]
			end
			end
			endfunction
			]])

			vim.g.slime_target = "tmux"
			vim.g.slime_no_mappings = true
			vim.g.slime_python_ipython = 1
			vim.g.slime_bracketed_paste = 1  -- Enable bracketed paste for multi-line R code
			-- Default tmux target (current window, right pane)
			vim.g.slime_default_config = {
				socket_name = "default",
				target_pane = "{right-of}",
			}
		end,
		config = function()
			vim.g.slime_input_pid = false
			vim.g.slime_suggest_default = true
			vim.g.slime_menu_config = false

			-- Configure slime target manually (no prompts)
			local function set_slime_target_manual()
				vim.fn.call("slime#config", {})
			end

			-- Auto-configure slime to right pane (.2)
			local function auto_config_slime()
				vim.b.slime_config = {
					socket_name = "default",
					target_pane = ":.2",
				}
				vim.notify("Slime configured to target pane :.2", vim.log.levels.INFO)
			end

			-- Send test message to verify connection
			local function test_slime()
				local config = vim.b.slime_config
				if config then
					vim.notify("Slime config: " .. vim.inspect(config), vim.log.levels.INFO)
					vim.fn["slime#send"]("# Test from Neovim\n")
				else
					vim.notify("No slime config set. Press <leader>ca to auto-configure.", vim.log.levels.WARN)
				end
			end

			-- Keybindings
			vim.keymap.set("n", "<leader>ca", auto_config_slime, { desc = "[a]uto-configure slime to right pane" })
			vim.keymap.set("n", "<leader>cr", function()
				-- Open tmux pane on the right and start R (remains open)
				vim.fn.system("tmux split-window -h -p 40 radian")
				auto_config_slime()

				-- Wait a moment for R to start, then load params if in a .qmd/.Rmd file
				vim.defer_fn(function()
					local current_file = vim.fn.expand("%:p")
					if current_file:match("%.qmd$") or current_file:match("%.Rmd$") then
						if _G.load_quarto_params then
							_G.load_quarto_params()
						end
					end
				end, 1500) -- Wait 1.5 seconds for R to start
			end, { desc = "open [r] console and configure slime" })
			vim.keymap.set("n", "<leader>cs", set_slime_target_manual, { desc = "[s]et slime target manually" })
			vim.keymap.set("n", "<leader>ct", test_slime, { desc = "[t]est slime connection" })
		end,
	},
}
