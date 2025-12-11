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
            names = false, -- disable "Blue", "Red" etc (too many false positives)
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
}
