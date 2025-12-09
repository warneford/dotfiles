return {
	{
		"R-nvim/R.nvim",
		lazy = false,
		config = function()
		-- Create a table with the options to be passed to setup()
		local opts = {
			-- Use radian-direnv wrapper to ensure VIRTUAL_ENV is loaded
			R_app = "radian-direnv",
			R_cmd = "R",

			-- Use nvim's built-in terminal (no external_term)
			-- This integrates better with toggleterm for shell/python terminals

			R_args = {},  -- radian doesn't need --quiet --no-save
			min_editor_width = 72,
			rconsole_width = 78,

			-- Enable sending complete statements (parenthesis blocks)
			parenblock = true,  -- Send all lines from opening to closing parenthesis
			bracketed_paste = true,  -- Use bracketed paste mode for multi-line code
			source_args = "echo=TRUE, print.eval=TRUE",  -- Show code when sourcing chunks
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

			-- Disable R.nvim's built-in LSP (use r_language_server from Mason instead)
			r_ls = {
				completion = false,
				hover = false,
				signature = false,
			},
		}

		-- Check if the environment variable "R_AUTO_START" exists.
		-- If using fish shell, you could put in your config.fish:
		-- alias r "R_AUTO_START=true nvim"
		if vim.env.R_AUTO_START == "true" then
			opts.auto_start = 1
			opts.objbr_auto_start = true
		end

		require("r").setup(opts)

		-- Auto-start R when opening R, quarto, or Rmd files
		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "r", "quarto", "rmd", "rmarkdown" },
			callback = function()
				-- Only auto-start if R is not already running
				-- vim.g.R_Nvim_status: 3 = ready to start, 7 = R running
				local attempts = 0
				local max_attempts = 20
				local function try_start_r()
					attempts = attempts + 1
					local status = vim.g.R_Nvim_status or 0
					if status >= 7 then
						return -- R already running
					end
					if status >= 3 then
						-- Ready to start R
						local ok, r_run = pcall(require, "r.run")
						if ok then
							r_run.start_R("R")
						end
					elseif attempts < max_attempts then
						vim.defer_fn(try_start_r, 300)
					end
				end
				vim.defer_fn(try_start_r, 300)
			end,
			once = true, -- Only run once per session
		})

		-- Wrap R.nvim's hl_code_bg function to prevent errors with special buffers
		-- This prevents "Parser could not be created" errors when switching to netrw/harpoon
		local quarto_module = require("r.quarto")
		local original_hl_code_bg = quarto_module.hl_code_bg
		quarto_module.hl_code_bg = function()
			local buftype = vim.bo.buftype
			local filetype = vim.bo.filetype
			-- Skip highlighting for special buffers
			if buftype ~= "" or filetype == "netrw" or filetype == "harpoon" or filetype == "" then
				return
			end
			-- Call original function for normal buffers
			pcall(original_hl_code_bg)
		end

		-- R.nvim sets all keybindings automatically
		-- See :RMapsDesc for the full list of available keybindings
		--
		-- Common keybindings (with LocalLeader = ,):
		-- ,rf - Start R
		-- ,rq - Quit R
		-- ,d  - Send line/statement and move down (RDSendLine) - with parenblock, sends complete statements! ⭐
		-- ,l  - Send line/statement, cursor stays (RSendLine)
		-- ,cd - Send chunk and move to next chunk
		-- ,cc - Send current chunk, cursor stays
		-- ,ro - Toggle object browser
		-- ,rv - View dataframe
		-- ,o  - Insert line output
		-- ,sc - Send piped chain
		--
		-- Pattern: Commands with "D" (like RDSendLine) move cursor Down after sending
		--
		-- Note: For Python/Julia/other languages, use vim-slime with <leader>cr
		-- R.nvim (,rf) provides the best R experience with object browser, help, etc.
	end,
	},
}
