return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		-- Defer setup to ensure colorscheme is fully loaded
		vim.defer_fn(function()
			-- Aqua/Gold custom theme
			local colors = {
				bg = "none",
				fg = "#c9d1d9",
				aqua = "#2dd4bf",
				teal = "#14b8a6",
				deep = "#134e4a",
				muted = "#6e7681",
				surface = "#1e2030",
				gold = "#fbbf24",
				gold_dark = "#92400e",
			}
			-- Terminal type themes
			local terminal_themes = {
				radian = {
					icon = "󰟔",
					name = "radian",
					bg = "#276dc3", -- R blue
					fg = "#f0f0f0", -- Light gray text
				},
				ipython = {
					icon = "\238\156\188", -- Python icon U+E73C
					name = "ipython",
					bg = "#3776ab", -- Python blue
					fg = "#ffd43b", -- Python yellow
				},
				shell = {
					icon = "\238\158\149", -- Shell icon U+E795 (nf-dev-terminal)
					name = "shell",
					bg = "#1e1e1e", -- Near black
					fg = "#ffffff", -- White
				},
				toggleterm = {
					icon = "\238\130\162", -- Terminal prompt icon
					name = "toggleterm",
					bg = colors.deep,
					fg = colors.aqua,
				},
				default = {
					icon = "\238\130\162", -- Terminal prompt icon
					name = "term",
					bg = colors.deep,
					fg = colors.aqua,
				},
			}

			-- Powerline semicircle characters
			local left_sep = "\238\130\182" -- U+E0B6
			local right_sep = "\238\130\180" -- U+E0B4

			-- Mode colors for statusline elements
			local mode_colors = {
				n = colors.teal,
				i = colors.gold,
				v = colors.aqua,
				V = colors.aqua,
				["\22"] = colors.aqua,
				c = "#fb7185",
				R = "#f97316",
				t = colors.teal,
			}

			local function get_mode_color()
				local mode = vim.fn.mode()
				return { fg = mode_colors[mode] or colors.teal, bg = "none" }
			end

			-- Section A content color (mode-aware bg AND fg)
			local function get_section_a_content()
				local mode = vim.fn.mode()
				return { bg = mode_colors[mode] or colors.teal, fg = colors.surface, gui = "bold" }
			end

			-- Section B separator color (fg matches section B's bg from theme)
			local section_b_bg = {
				n = colors.deep,
				i = colors.gold_dark,
				v = colors.deep,
				V = colors.deep,
				["\22"] = colors.deep,
				c = "#9f1239",
				R = "#7c2d12",
				t = colors.deep,
			}

			local function get_section_b_sep()
				local mode = vim.fn.mode()
				return { fg = section_b_bg[mode] or colors.deep, bg = "none" }
			end

			-- Section B content fg colors (mode-aware)
			local section_b_fg = {
				n = colors.aqua,
				i = colors.gold,
				v = colors.aqua,
				V = colors.aqua,
				["\22"] = colors.aqua,
				c = "#1e1e2e",
				R = "#fb923c",
				t = colors.aqua,
			}

			local function get_section_b_content()
				local mode = vim.fn.mode()
				return { bg = section_b_bg[mode] or colors.deep, fg = section_b_fg[mode] or colors.aqua }
			end

			-- Section X (filetype) - static colors but function-based for persistence
			local function get_section_x_sep()
				return { fg = colors.deep, bg = "none" }
			end

			local function get_section_x_content()
				return { bg = colors.deep, fg = colors.aqua }
			end

			-- Section Z (location) - static colors but function-based for persistence
			local function get_section_z_sep()
				return { fg = colors.teal, bg = "none" }
			end

			local function get_section_z_content()
				return { bg = colors.teal, fg = colors.surface, gui = "bold" }
			end

			-- Winbar colors (peach pill for files)
			local function get_winbar_sep()
				return { fg = "#fab387", bg = "none" }
			end

			local function get_winbar_content()
				return { bg = "#fab387", fg = "#1e1e2e", gui = "bold" }
			end

			-- Theme with transparent section C backgrounds
			local transparent_theme = {
				normal = {
					a = { bg = colors.teal, fg = colors.surface, gui = "bold" },
					b = { bg = colors.deep, fg = colors.aqua },
					c = { bg = "none", fg = colors.muted },
				},
				insert = {
					a = { bg = colors.gold, fg = colors.surface, gui = "bold" },
					b = { bg = colors.gold_dark, fg = colors.gold },
					c = { bg = "none", fg = colors.muted },
				},
				visual = {
					a = { bg = colors.aqua, fg = colors.surface, gui = "bold" },
					b = { bg = colors.deep, fg = colors.aqua },
					c = { bg = "none", fg = colors.muted },
				},
				replace = {
					a = { bg = "#f97316", fg = colors.surface, gui = "bold" },
					b = { bg = "#7c2d12", fg = "#fb923c" },
					c = { bg = "none", fg = colors.muted },
				},
				command = {
					a = { bg = "#fb7185", fg = colors.surface, gui = "bold" },
					b = { bg = "#9f1239", fg = "#1e1e2e" },
					c = { bg = "none", fg = colors.muted },
				},
				terminal = {
					a = { bg = colors.teal, fg = colors.surface, gui = "bold" },
					b = { bg = colors.deep, fg = colors.aqua },
					c = { bg = "none", fg = colors.muted },
				},
				inactive = {
					a = { bg = "none", fg = colors.muted },
					b = { bg = "none", fg = colors.muted },
					c = { bg = "none", fg = colors.muted },
				},
			}

			-- Terminal type detection (for winbar display)
			local function terminal_type()
				if vim.bo.buftype ~= "terminal" then
					return nil
				end
				local bufname = vim.api.nvim_buf_get_name(0)
				if bufname:match("[Rr]adian") then
					return terminal_themes.radian
				elseif bufname:match("[Ii][Pp]ython") or bufname:match("ipython%-direnv") then
					return terminal_themes.ipython
				elseif bufname:match("zsh") or bufname:match("bash") then
					return terminal_themes.shell
				elseif vim.bo.filetype == "toggleterm" then
					return terminal_themes.toggleterm
				end
				return terminal_themes.default
			end

			-- Check if current buffer is a terminal
			local function is_terminal()
				return vim.bo.buftype == "terminal"
			end

			-- Check if current buffer is NOT a terminal
			local function is_not_terminal()
				return vim.bo.buftype ~= "terminal"
			end

			require("lualine").setup({
				options = {
					icons_enabled = true,
					theme = transparent_theme,
					component_separators = { left = "", right = "" },
					section_separators = { left = "", right = "" },
					disabled_filetypes = {
						statusline = { "aerial" },
						winbar = { "neo-tree", "Trouble", "alpha", "TelescopePrompt", "TelescopeResults", "aerial" },
					},
					ignore_focus = { "TelescopePrompt", "TelescopeResults", "aerial" },
					always_divide_middle = true,
					globalstatus = true,
				},
				sections = {
					lualine_a = {
						{
							function()
								return left_sep
							end,
							padding = { left = 0, right = 0 },
							color = get_mode_color,
						},
						{ "mode", color = get_section_a_content },
						{
							function()
								return right_sep
							end,
							padding = { left = 0, right = 0 },
							color = get_mode_color,
						},
					},
					lualine_b = {
						{
							function()
								return left_sep
							end,
							padding = { left = 0, right = 0 },
							color = get_section_b_sep,
						},
						{ "branch", icon = "󰘬", color = get_section_b_content },
						{
							"diff",
							symbols = { added = "󰐕 ", modified = "󰏫 ", removed = "󰍴 " },
							color = get_section_b_content,
						},
						{
							"diagnostics",
							sources = { "nvim_diagnostic", "nvim_lsp" },
							sections = { "error", "warn", "info", "hint" },
							symbols = { error = "󰅚 ", warn = "󰀪 ", info = "󰋽 ", hint = "󰌵 " },
							colored = false, -- disable to use our persistent color
							update_in_insert = false,
							always_visible = false,
							color = get_section_b_content,
						},
						{
							function()
								return right_sep
							end,
							padding = { left = 0, right = 0 },
							color = get_section_b_sep,
						},
					},
					lualine_c = {},
					lualine_x = {
						{
							function()
								return left_sep
							end,
							color = get_section_b_sep,
							padding = { left = 0, right = 0 },
							cond = is_not_terminal,
						},
						{ "filetype", color = get_section_b_content, cond = is_not_terminal },
						{
							function()
								return right_sep
							end,
							color = get_section_b_sep,
							padding = { left = 0, right = 0 },
							cond = is_not_terminal,
						},
					},
					lualine_y = {},
					lualine_z = {
						{
							function()
								return left_sep
							end,
							color = get_mode_color,
							padding = { left = 0, right = 0 },
						},
						{ "location", color = get_section_a_content },
						{
							function()
								return right_sep
							end,
							color = get_mode_color,
							padding = { left = 0, right = 0 },
						},
					},
				},
				inactive_sections = {
					lualine_a = {},
					lualine_b = {},
					lualine_c = { "filename" },
					lualine_x = { "location" },
					lualine_y = {},
					lualine_z = {},
				},
				tabline = {},
				winbar = {
					lualine_c = {
						-- Opening pill separator (peach for files, deep teal for terminals)
						{
							function()
								return left_sep
							end,
							color = get_winbar_sep,
							padding = { left = 0, right = 0 },
							cond = is_not_terminal,
						},
						{
							function()
								return left_sep
							end,
							color = function()
								local t = terminal_type()
								return { fg = t and t.bg or colors.deep, bg = "none" }
							end,
							padding = { left = 0, right = 0 },
							cond = is_terminal,
						},
						-- Icon (filetype icon for files, terminal type icon for terminals)
						{
							function()
								local ft = vim.bo.filetype
								if ft == "" then return "" end
								local icon = require("nvim-web-devicons").get_icon_by_filetype(ft)
								return icon or ""
							end,
							padding = { left = 1, right = 0 },
							color = get_winbar_content,
							cond = is_not_terminal,
						},
						{
							function()
								local t = terminal_type()
								return t and t.icon or ""
							end,
							padding = { left = 1, right = 0 },
							color = function()
								local t = terminal_type()
								return { bg = t and t.bg or colors.deep, fg = t and t.fg or colors.aqua, gui = "bold" }
							end,
							cond = is_terminal,
						},
						-- Name (filename for files, terminal name for terminals)
						{
							function()
								local name = vim.fn.expand("%:t")
								if name == "" then name = "[No Name]" end
								if vim.bo.modified then name = name .. " ●" end
								if vim.bo.readonly then name = name .. " " end
								return name
							end,
							color = get_winbar_content,
							padding = { left = 0, right = 1 },
							cond = is_not_terminal,
						},
						{
							function()
								local t = terminal_type()
								return t and t.name or "term"
							end,
							padding = { left = 1, right = 1 },
							color = function()
								local t = terminal_type()
								return { bg = t and t.bg or colors.deep, fg = t and t.fg or colors.aqua, gui = "bold" }
							end,
							cond = is_terminal,
						},
						-- Closing pill separator
						{
							function()
								return right_sep
							end,
							color = get_winbar_sep,
							padding = { left = 0, right = 0 },
							cond = is_not_terminal,
						},
						{
							function()
								return right_sep
							end,
							color = function()
								local t = terminal_type()
								return { fg = t and t.bg or colors.deep, bg = "none" }
							end,
							padding = { left = 0, right = 0 },
							cond = is_terminal,
						},
					},
				},
				inactive_winbar = {
					lualine_c = {
						-- File icon (for non-terminals)
						{
							"filetype",
							icon_only = true,
							padding = { left = 1, right = 0 },
							cond = is_not_terminal,
						},
						-- Terminal icon (for terminals)
						{
							function()
								local t = terminal_type()
								return t and t.icon or ""
							end,
							padding = { left = 1, right = 0 },
							cond = is_terminal,
						},
						-- Filename (for non-terminals)
						{
							"filename",
							path = 0,
							symbols = { modified = " ●", readonly = " ", unnamed = "[No Name]" },
							cond = is_not_terminal,
						},
						-- Terminal name (for terminals)
						{
							function()
								local t = terminal_type()
								return t and t.name or "term"
							end,
							padding = { left = 1, right = 0 },
							cond = is_terminal,
						},
					},
				},
				extensions = { "fugitive", "trouble" },
			})

			-- Set winbar and section C backgrounds to transparent after lualine creates them
			-- This overrides any theme defaults (like rose-pine's foam blue for insert mode)
			local function set_transparent_backgrounds()
				-- Core statusline/winbar highlights
				vim.api.nvim_set_hl(0, "StatusLineTerm", { bg = "none" })
				vim.api.nvim_set_hl(0, "StatusLineTermNC", { bg = "none" })
				vim.api.nvim_set_hl(0, "lualine_c_winbar", { bg = "none" })
				vim.api.nvim_set_hl(0, "lualine_c_winbar_inactive", { bg = "none" })
				-- Force all section C modes to be transparent (prevents rose-pine foam blue in terminals)
				for _, mode in ipairs({ "normal", "insert", "visual", "replace", "command", "terminal", "inactive" }) do
					vim.api.nvim_set_hl(0, "lualine_c_" .. mode, { bg = "none", fg = colors.muted })
				end
			end
			set_transparent_backgrounds()

			-- Fix winbar highlights around floating windows (Telescope, etc.)
			-- lualine.refresh() doesn't restore highlight groups, only setup() does
			local function restore_lualine_highlights()
				require("lualine").setup()
				set_transparent_backgrounds()
			end

			-- Keep lualine section C backgrounds transparent
			vim.api.nvim_create_autocmd({ "WinEnter", "WinLeave", "BufEnter", "BufLeave" }, {
				callback = function()
					set_transparent_backgrounds()
				end,
			})

			-- Full restore when entering/leaving floating windows
			vim.api.nvim_create_autocmd("WinEnter", {
				callback = function()
					local win = vim.api.nvim_get_current_win()
					local ok, config = pcall(vim.api.nvim_win_get_config, win)
					local is_float = ok and config.relative ~= ""
					if is_float then
						-- Entering a float - restore highlights immediately
						vim.schedule(restore_lualine_highlights)
					end
				end,
			})
			vim.api.nvim_create_autocmd("WinClosed", {
				callback = function()
					-- After any window closes, restore highlights
					vim.schedule(restore_lualine_highlights)
				end,
			})

			-- Fix lualine when aerial is open
			local aerial_was_open = false
			local function aerial_is_open()
				for _, win in ipairs(vim.api.nvim_list_wins()) do
					local buf = vim.api.nvim_win_get_buf(win)
					local ft = vim.api.nvim_buf_get_option(buf, "filetype")
					if ft == "aerial" then
						return true
					end
				end
				return false
			end

			vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter", "WinClosed" }, {
				group = vim.api.nvim_create_augroup("LualineAerialFix", { clear = true }),
				callback = function()
					local is_open = aerial_is_open()
					if is_open or aerial_was_open then
						vim.schedule(restore_lualine_highlights)
					end
					aerial_was_open = is_open
				end,
			})

			-- Refresh lualine when any terminal is opened or focus changes with terminals
			local last_buftype = vim.bo.buftype
			vim.api.nvim_create_autocmd({ "TermOpen", "WinEnter", "BufEnter" }, {
				group = vim.api.nvim_create_augroup("LualineTermFix", { clear = true }),
				callback = function()
					local current_buftype = vim.bo.buftype
					-- Refresh when entering/leaving terminal buffers
					if current_buftype == "terminal" or last_buftype == "terminal" then
						vim.schedule(restore_lualine_highlights)
					end
					last_buftype = current_buftype
				end,
			})
		end, 100) -- 100ms delay for colorscheme to fully load
	end,
}
