return {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        require("lualine").setup({
            options = {
                icons_enabled = true,
                theme = "auto",
                component_separators = { left = "|", right = "|" },
                section_separators = { left = "", right = "" },
                disabled_filetypes = {
                    statusline = {},
                    winbar = {},
                },
                ignore_focus = {},
                always_divide_middle = true,
                globalstatus = true, -- single statusline for all windows
                refresh = {
                    statusline = 1000,
                    tabline = 1000,
                    winbar = 1000,
                },
            },
            sections = {
                lualine_a = { "mode" },
                lualine_b = {
                    "branch",
                    "diff",
                    {
                        "diagnostics",
                        sources = { "nvim_diagnostic", "nvim_lsp" },
                        sections = { "error", "warn" },
                        symbols = { error = "E", warn = "W" },
                        colored = true,
                        update_in_insert = false,
                        always_visible = false,
                    },
                },
                lualine_c = {},
                lualine_x = { "filetype" },
                lualine_y = { "progress" },
                lualine_z = { "location" },
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
                lualine_z = {
                    { "filename", path = 0 },
                },
            },
            inactive_winbar = {
                lualine_z = {
                    { "filename", path = 0 },
                },
            },
            extensions = { "fugitive", "trouble" },
        })
    end,
}
