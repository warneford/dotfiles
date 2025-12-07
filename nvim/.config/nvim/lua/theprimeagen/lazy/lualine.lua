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

        -- Terminal type detection (for buffers without filetype)
        local function terminal_type()
            if vim.bo.buftype ~= "terminal" then
                return ""
            end
            local bufname = vim.api.nvim_buf_get_name(0)
            if bufname:match("[Rr]adian") then
                return "󰟔 ∠ radian"  -- R logo + angle symbol
            elseif bufname:match("[Ii][Pp]ython") or bufname:match("ipython%-direnv") then
                return " ipython"
            elseif bufname:match("zsh") or bufname:match("bash") then
                return " shell"
            elseif vim.bo.filetype == "toggleterm" then
                return ""  -- Let filetype component handle it
            end
            return " term"
        end

        require("lualine").setup({
            options = {
                icons_enabled = true,
                theme = aqua_forest,
                component_separators = { left = "", right = "" },
                section_separators = { left = "", right = "" },
                disabled_filetypes = {
                    statusline = {},
                    winbar = { "neo-tree", "Trouble", "alpha", "toggleterm" },
                },
                ignore_focus = {},
                always_divide_middle = true,
                globalstatus = true,
            },
            sections = {
                lualine_a = {
                    {
                        function() return "" end,
                        padding = { left = 0, right = 0 },
                        color = function()
                            local mode_colors = {
                                n = colors.teal,
                                i = colors.gold,
                                v = colors.aqua,
                                V = colors.aqua,
                                ["\22"] = colors.aqua,
                                c = "#fb7185",
                                R = "#f97316",
                            }
                            local mode = vim.fn.mode()
                            return { fg = mode_colors[mode] or colors.teal, bg = "none" }
                        end,
                    },
                    { os_icon, padding = { left = 1, right = 1 } },
                    { "mode" },
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
                        function() return "" end,
                        color = { fg = colors.deep, bg = "none" },
                        padding = { left = 0, right = 0 },
                    },
                    {
                        "filetype",
                        icon_only = false,
                        padding = { left = 1, right = 1 },
                        color = { bg = colors.deep, fg = colors.aqua },
                        cond = function() return vim.bo.filetype ~= "" end,
                    },
                    {
                        terminal_type,
                        padding = { left = 1, right = 1 },
                        color = { bg = colors.deep, fg = colors.aqua },
                        cond = function() return vim.bo.filetype == "" and terminal_type() ~= "" end,
                    },
                    {
                        function() return "" end,
                        color = { fg = colors.deep, bg = "none" },
                        padding = { left = 0, right = 0 },
                    },
                },
                lualine_y = {},
                lualine_z = {
                    {
                        function() return "" end,
                        color = { fg = colors.teal, bg = "none" },
                        padding = { left = 0, right = 0 },
                    },
                    {
                        "location",
                        padding = { left = 1, right = 1 },
                        color = { bg = colors.teal, fg = colors.surface, gui = "bold" },
                    },
                    {
                        function() return "" end,
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
                    {
                        function() return "" end,
                        color = { fg = "#fab387", bg = "none" },
                        padding = { left = 0, right = 0 },
                    },
                    {
                        "filetype",
                        icon_only = true,
                        padding = { left = 1, right = 0 },
                        color = { bg = "#fab387", fg = "#1e1e2e", gui = "bold" },
                    },
                    {
                        "filename",
                        path = 0,
                        symbols = { modified = " ●", readonly = " ", unnamed = "[No Name]" },
                        color = { bg = "#fab387", fg = "#1e1e2e", gui = "bold" },
                        padding = { left = 0, right = 1 },
                    },
                    {
                        function() return "" end,
                        color = { fg = "#fab387", bg = "none" },
                        padding = { left = 0, right = 0 },
                    },
                },
            },
            inactive_winbar = {
                lualine_c = {
                    { "filetype", icon_only = true, padding = { left = 1, right = 0 } },
                    {
                        "filename",
                        path = 0,
                        symbols = { modified = " ●", readonly = " ", unnamed = "[No Name]" },
                    },
                },
            },
            extensions = { "fugitive", "trouble" },
        })

        -- Clear winbar background highlights
        vim.api.nvim_set_hl(0, "lualine_c_normal", { bg = "none" })
        vim.api.nvim_set_hl(0, "lualine_c_insert", { bg = "none" })
        vim.api.nvim_set_hl(0, "lualine_c_visual", { bg = "none" })
        vim.api.nvim_set_hl(0, "lualine_c_command", { bg = "none" })
        vim.api.nvim_set_hl(0, "lualine_c_replace", { bg = "none" })
        vim.api.nvim_set_hl(0, "lualine_c_inactive", { bg = "none" })

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
