-- Highlight color codes with their actual color
-- https://github.com/catgoose/nvim-colorizer.lua
return {
    "catgoose/nvim-colorizer.lua",
    event = "BufReadPost",
    opts = {
        filetypes = { "*" },
        user_default_options = {
            mode = "virtualtext", -- "background" | "foreground" | "virtualtext"
            virtualtext = "■",
            virtualtext_inline = true,
            names = false, -- disable CSS names like "Blue", "Red" (too many false positives)
            names_custom = function()
                -- R's 657 named colors (gray50, steelblue, etc)
                return require("config.r_colors")
            end,
            RGB = true, -- #RGB hex
            RRGGBB = true, -- #RRGGBB hex
            RRGGBBAA = true, -- #RRGGBBAA hex
            rgb_fn = true, -- CSS rgb()
            hsl_fn = true, -- CSS hsl()
            css = false, -- CSS features (border-color, etc)
            css_fn = false, -- CSS functions
            tailwind = false, -- Tailwind colors
        },
    },
    config = function(_, opts)
        require("colorizer").setup(opts)

        -- Reattach colorizer after switching windows/buffers (fixes aerial/fzf-lua clearing it)
        -- Colorizer reattaches on ColorScheme events, so we trigger that
        vim.api.nvim_create_autocmd({ "BufEnter" }, {
            callback = function()
                vim.defer_fn(function()
                    -- Trigger ColorScheme event without changing colorscheme
                    vim.api.nvim_exec_autocmds("ColorScheme", { modeline = false })
                end, 1)
            end,
        })
    end,
}
