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
                bg = "#276dc3",      -- R blue
                fg = "#f0f0f0",      -- Light gray text
            },
            ipython = {
                icon = "\238\156\188",  -- Python icon U+E73C
                name = "ipython",
                bg = "#3776ab",      -- Python blue
                fg = "#ffd43b",      -- Python yellow
            },
            shell = {
                icon = "\238\158\149",  -- Shell icon U+E795 (nf-dev-terminal)
                name = "shell",
                bg = "#1e1e1e",      -- Near black
                fg = "#ffffff",      -- White
            },
            toggleterm = {
                icon = "\238\130\162",  -- Terminal prompt icon
                name = "toggleterm",
                bg = colors.deep,
                fg = colors.aqua,
            },
            default = {
                icon = "\238\130\162",  -- Terminal prompt icon
                name = "term",
                bg = colors.deep,
                fg = colors.aqua,
            },
        }

        -- Powerline semicircle characters
        local left_sep = "\238\130\182"   -- U+E0B6
        local right_sep = "\238\130\180"  -- U+E0B4

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

        local aqua_forest = {
            normal = {
                a = { bg = colors.teal, fg = colors.surface, gui = "bold" },
                b = { bg = colors.deep, fg = colors.aqua },
                c = { bg = colors.bg, fg = colors.muted },
            },
            insert = {
                a = { bg = colors.gold, fg = colors.surface, gui = "bold" },
                b = { bg = colors.gold_dark, fg = colors.gold },
            },
            visual = {
                a = { bg = colors.aqua, fg = colors.surface, gui = "bold" },
                b = { bg = colors.deep, fg = colors.aqua },
            },
            replace = {
                a = { bg = "#f97316", fg = colors.surface, gui = "bold" },
                b = { bg = "#7c2d12", fg = "#fb923c" },
            },
            command = {
                a = { bg = "#fb7185", fg = colors.surface, gui = "bold" },
                b = { bg = "#9f1239", fg = "#1e1e2e" },
            },
            terminal = {
                a = { bg = colors.teal, fg = colors.surface, gui = "bold" },
                b = { bg = colors.deep, fg = colors.aqua },
                c = { bg = colors.bg, fg = colors.muted },
            },
            inactive = {
                a = { bg = colors.bg, fg = colors.muted },
                b = { bg = colors.bg, fg = colors.muted },
                c = { bg = colors.bg, fg = colors.muted },
            },
        }

        -- OS icon detection
        local function os_icon()
            local os = vim.loop.os_uname().sysname
            if os == "Darwin" then
                return ""
            elseif os == "Linux" then
                return ""
            elseif os == "Windows_NT" then
                return ""
            end
            return ""
        end

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
                theme = aqua_forest,
                component_separators = { left = "", right = "" },
                section_separators = { left = "", right = "" },
                disabled_filetypes = {
                    statusline = {},
                    winbar = { "neo-tree", "Trouble", "alpha" },
                },
                ignore_focus = {},
                always_divide_middle = true,
                globalstatus = true,
            },
            sections = {
                lualine_a = {
                    {
                        function() return left_sep end,
                        padding = { left = 0, right = 0 },
                        color = get_mode_color,
                    },
                    { os_icon, padding = { left = 1, right = 1 } },
                    { "mode" },
                    {
                        function() return right_sep end,
                        padding = { left = 0, right = 0 },
                        color = get_mode_color,
                    },
                },
                lualine_b = {
                    { "branch", icon = "󰘬" },
                    { "diff", symbols = { added = "󰐕 ", modified = "󰏫 ", removed = "󰍴 " } },
                    {
                        "diagnostics",
                        sources = { "nvim_diagnostic", "nvim_lsp" },
                        sections = { "error", "warn", "info", "hint" },
                        symbols = { error = "󰅚 ", warn = "󰀪 ", info = "󰋽 ", hint = "󰌵 " },
                        colored = true,
                        update_in_insert = false,
                        always_visible = false,
                    },
                },
                lualine_c = {},
                lualine_x = {
                    {
                        function() return left_sep end,
                        color = { fg = colors.deep, bg = "none" },
                        padding = { left = 0, right = 0 },
                        cond = is_not_terminal,
                    },
                    {
                        "filetype",
                        icon_only = false,
                        padding = { left = 1, right = 1 },
                        color = { bg = colors.deep, fg = colors.aqua },
                        cond = is_not_terminal,
                    },
                    {
                        function() return right_sep end,
                        color = { fg = colors.deep, bg = "none" },
                        padding = { left = 0, right = 0 },
                        cond = is_not_terminal,
                    },
                },
                lualine_y = {},
                lualine_z = {
                    {
                        function() return left_sep end,
                        color = { fg = colors.teal, bg = "none" },
                        padding = { left = 0, right = 0 },
                    },
                    {
                        "location",
                        padding = { left = 1, right = 1 },
                        color = { bg = colors.teal, fg = colors.surface, gui = "bold" },
                    },
                    {
                        function() return right_sep end,
                        color = { fg = colors.teal, bg = "none" },
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
                        function() return left_sep end,
                        color = { fg = "#fab387", bg = "none" },
                        padding = { left = 0, right = 0 },
                        cond = is_not_terminal,
                    },
                    {
                        function() return left_sep end,
                        color = function()
                            local t = terminal_type()
                            return { fg = t and t.bg or colors.deep, bg = "none" }
                        end,
                        padding = { left = 0, right = 0 },
                        cond = is_terminal,
                    },
                    -- Icon (filetype icon for files, terminal type icon for terminals)
                    {
                        "filetype",
                        icon_only = true,
                        padding = { left = 1, right = 0 },
                        color = { bg = "#fab387", fg = "#1e1e2e", gui = "bold" },
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
                        "filename",
                        path = 0,
                        symbols = { modified = " ●", readonly = " ", unnamed = "[No Name]" },
                        color = { bg = "#fab387", fg = "#1e1e2e", gui = "bold" },
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
                        function() return right_sep end,
                        color = { fg = "#fab387", bg = "none" },
                        padding = { left = 0, right = 0 },
                        cond = is_not_terminal,
                    },
                    {
                        function() return right_sep end,
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

        -- Fix highlight issues with floating windows (telescope, etc.)
        local function fix_colors()
            vim.schedule(function()
                if ColorMyPencils then
                    ColorMyPencils()
                end
            end)
        end

        local last_was_float = false
        vim.api.nvim_create_autocmd("WinLeave", {
            callback = function()
                local win = vim.api.nvim_get_current_win()
                local config = vim.api.nvim_win_get_config(win)
                last_was_float = config.relative ~= ""
            end,
        })
        vim.api.nvim_create_autocmd("WinEnter", {
            callback = function()
                local win = vim.api.nvim_get_current_win()
                local config = vim.api.nvim_win_get_config(win)
                local is_float = config.relative ~= ""
                -- Fix when entering or leaving floating windows
                if is_float or last_was_float then
                    last_was_float = false
                    fix_colors()
                end
            end,
        })

        -- Fix colors on any buffer/window change
        vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
            callback = function()
                fix_colors()
            end,
        })
        end, 100) -- 100ms delay for colorscheme to fully load
    end,
}
