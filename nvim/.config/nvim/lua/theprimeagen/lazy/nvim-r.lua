return {
	{
		"R-nvim/R.nvim",
		lazy = false,
		config = function()
		-- Create a table with the options to be passed to setup()
		local opts = {
			-- Use radian-direnv wrapper to ensure VIRTUAL_ENV is loaded
			-- This is needed because tmux split-window doesn't inherit direnv env
			R_app = "radian-direnv",
			R_cmd = "R",

			-- Use external tmux terminal instead of built-in (avoids TCP issues)
			-- -l 80: fixed width (percentage -p doesn't work in all contexts)
			external_term = "tmux split-window -h -l 80",

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
	{
		-- Completion source for R.nvim - provides Quarto YAML frontmatter completion
		"R-nvim/cmp-r",
		config = function()
			-- Find Quarto's yaml-intelligence file dynamically (works on macOS and Linux)
			local function find_quarto_intel()
				local handle = io.popen("quarto --paths 2>/dev/null | grep share | head -1")
				if handle then
					local share_path = handle:read("*l")
					handle:close()
					if share_path then
						local intel_path = share_path .. "/editor/tools/yaml/yaml-intelligence-resources.json"
						if vim.fn.filereadable(intel_path) == 1 then
							return intel_path
						end
					end
				end
				-- Fallback paths
				local fallbacks = {
					"/Applications/quarto/share/editor/tools/yaml/yaml-intelligence-resources.json", -- macOS
					vim.fn.expand("~/.local/quarto/share/editor/tools/yaml/yaml-intelligence-resources.json"), -- Linux user install
					"/usr/local/quarto/share/editor/tools/yaml/yaml-intelligence-resources.json", -- Linux system install
				}
				for _, path in ipairs(fallbacks) do
					if vim.fn.filereadable(path) == 1 then
						return path
					end
				end
				return nil
			end

			require("cmp_r").setup({
				filetypes = { "r", "rmd", "quarto" },
				doc_width = 58,
				quarto_intel = find_quarto_intel(),
			})
		end,
	},
}
