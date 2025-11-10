return {
	"R-nvim/R.nvim",
	lazy = false,
	config = function()
		-- Create a table with the options to be passed to setup()
		local opts = {
			-- Use radian instead of base R
			R_app = "radian",
			R_cmd = "R",

			-- Use external tmux terminal instead of built-in (avoids TCP issues)
			external_term = "tmux split-window -h -p 40",

			R_args = {},  -- radian doesn't need --quiet --no-save
			min_editor_width = 72,
			rconsole_width = 78,

			-- Enable sending complete statements (parenthesis blocks)
			parenblock = true,  -- Send all lines from opening to closing parenthesis
			bracketed_paste = true,  -- Use bracketed paste mode for multi-line code
			objbr_mappings = { -- Object browser keymap
				c = "class", -- Call R command `class()`
				["<localleader>gg"] = "head({object}, n = 15)", -- Use {object} notation to write arbitrary R code.
			},
			disable_cmds = {
				"RClearConsole",
				"RCustomStart",
				"RSPlot",
				"RSaveClose",
			},
			-- Disable Quarto code chunk highlighting to prevent errors with special buffers
			hl_term = false,
		}

		-- Check if the environment variable "R_AUTO_START" exists.
		-- If using fish shell, you could put in your config.fish:
		-- alias r "R_AUTO_START=true nvim"
		if vim.env.R_AUTO_START == "true" then
			opts.auto_start = 1
			opts.objbr_auto_start = true
		end

		require("r").setup(opts)

		-- Wrap R.nvim's hl_code_bg function to prevent errors with special buffers
		-- This prevents "Parser could not be created" errors when switching to neo-tree/harpoon
		local quarto_module = require("r.quarto")
		local original_hl_code_bg = quarto_module.hl_code_bg
		quarto_module.hl_code_bg = function()
			local buftype = vim.bo.buftype
			local filetype = vim.bo.filetype
			-- Skip highlighting for special buffers
			if buftype ~= "" or filetype == "neo-tree" or filetype == "harpoon" or filetype == "" then
				return
			end
			-- Call original function for normal buffers
			pcall(original_hl_code_bg)
		end

		-- Keybindings
		vim.keymap.set("n", "<localleader>rf", "<Plug>RStart", { desc = "Start R" })
		vim.keymap.set("n", "<localleader>rq", "<Plug>RClose", { desc = "Quit R" })

		-- Send line/statement to R
		-- TODO: Add cursor advancement to next non-comment line after sending
		-- Currently cursor stays in place after ,l
		vim.keymap.set("n", "<localleader>l", "<Plug>RDSendLine", { desc = "Send line to R" })

		vim.keymap.set("v", "<localleader>l", "<Plug>RSendSelection", { desc = "Send selection to R" })
		vim.keymap.set("n", "<localleader>rr", "<Plug>RDSendFile", { desc = "Send file to R" })
		vim.keymap.set("n", "<localleader>p", "<Plug>RPlot", { desc = "Show R plot" })
		vim.keymap.set("n", "<localleader>o", "<Plug>ROBToggle", { desc = "Toggle object browser" })
		vim.keymap.set("n", "<localleader>h", "<Plug>RHelp", { desc = "R help for word under cursor" })
		vim.keymap.set("n", "<localleader>v", "<Plug>RViewDF", { desc = "View dataframe" })
	end,
}
