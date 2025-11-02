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

			vim.g.slime_target = "neovim"
			vim.g.slime_no_mappings = true
			vim.g.slime_python_ipython = 1
		end,
		config = function()
			vim.g.slime_input_pid = false
			vim.g.slime_suggest_default = true
			vim.g.slime_menu_config = false
			vim.g.slime_neovim_ignore_unlisted = true

			local function mark_terminal()
				local job_id = vim.b.terminal_job_id
				vim.print("job_id: " .. job_id)
			end

			local function set_terminal()
				vim.fn.call("slime#config", {})
			end

			-- Keybindings
			vim.keymap.set("n", "<leader>cm", mark_terminal, { desc = "[m]ark terminal" })
			vim.keymap.set("n", "<leader>cs", set_terminal, { desc = "[s]et terminal" })

			-- Helper functions to open new terminals (horizontal split below)
			local function new_terminal(lang)
				vim.cmd("split term://" .. lang)
				vim.cmd("wincmd J") -- Move window to bottom
				vim.cmd("resize 10") -- Set height to 10 lines
			end

			vim.keymap.set("n", "<leader>cr", function()
				new_terminal("R --no-save")
			end, { desc = "new [R] terminal" })

			vim.keymap.set("n", "<leader>cp", function()
				new_terminal("ipython --no-confirm-exit")
			end, { desc = "new [p]ython/ipython terminal" })

			vim.keymap.set("n", "<leader>cj", function()
				new_terminal("julia")
			end, { desc = "new [j]ulia terminal" })

			vim.keymap.set("n", "<leader>cn", function()
				new_terminal(vim.env.SHELL or "zsh")
			end, { desc = "[n]ew terminal" })
		end,
	},
}
