function ColorMyPencils(color)
  color = color or "rose-pine-moon"
  vim.cmd.colorscheme(color)

  -- Helper to get hex color from highlight group
  local function get_hl_color(name, attr)
    local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
    if hl[attr] then
      return string.format("#%06x", hl[attr])
    end
    return nil
  end

  -- Preserve fg colors before making bg transparent
  local normal_fg = get_hl_color("Normal", "fg") or "#e0def4"
  local float_fg = get_hl_color("NormalFloat", "fg") or normal_fg

  vim.api.nvim_set_hl(0, "Normal", { fg = normal_fg, bg = "none" })
  vim.api.nvim_set_hl(0, "NormalFloat", { fg = float_fg, bg = "none" })

  -- Diff highlights: visible backgrounds for transparent bg (tokyonight-inspired)
  -- fg = "NONE" preserves syntax highlighting inside diff hunks
  vim.api.nvim_set_hl(0, "DiffAdd", { bg = "#2b485a" })
  vim.api.nvim_set_hl(0, "DiffDelete", { bg = "#52313f" })
  vim.api.nvim_set_hl(0, "DiffChange", { bg = "#272d43" })
  vim.api.nvim_set_hl(0, "DiffText", { bg = "#394b70" })

  -- Diffview-specific highlights
  vim.api.nvim_set_hl(0, "DiffviewDiffAddAsDelete", { bg = "#52313f" })
  vim.api.nvim_set_hl(0, "DiffviewDiffDelete", { fg = "#6e6a86", bg = "none" })
  vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
  vim.api.nvim_set_hl(0, "WinBar", { bg = "none" })
  vim.api.nvim_set_hl(0, "WinBarNC", { bg = "none", fg = "#6e7681" })
  vim.api.nvim_set_hl(0, "StatusLine", { bg = "none" })
  vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "none" })
  vim.api.nvim_set_hl(0, "StatusLineTerm", { bg = "none" })
  vim.api.nvim_set_hl(0, "StatusLineTermNC", { bg = "none" })

  -- Lualine section c backgrounds (between left and right pills)
  vim.api.nvim_set_hl(0, "lualine_c_normal", { bg = "none" })
  vim.api.nvim_set_hl(0, "lualine_c_insert", { bg = "none" })
  vim.api.nvim_set_hl(0, "lualine_c_visual", { bg = "none" })
  vim.api.nvim_set_hl(0, "lualine_c_command", { bg = "none" })
  vim.api.nvim_set_hl(0, "lualine_c_replace", { bg = "none" })
  vim.api.nvim_set_hl(0, "lualine_c_inactive", { bg = "none" })
  vim.api.nvim_set_hl(0, "lualine_c_terminal", { bg = "none" })

  -- Lualine winbar backgrounds
  vim.api.nvim_set_hl(0, "lualine_c_winbar", { bg = "none" })
  vim.api.nvim_set_hl(0, "lualine_c_winbar_inactive", { bg = "none" })

  -- Colorcolumn: subtle vertical line at 80 chars
  -- Options to try:
  -- Subtle dark gray: { bg = "#1c1c1c" }
  -- Very subtle: { bg = "#0a0a0a" }
  -- Rose-pine inspired muted: { bg = "#26233a" }
  -- Just a thin line (no bg): { fg = "#6e6a86" }
  vim.api.nvim_set_hl(0, "ColorColumn", { bg = "#6e6a86" })

  -- Snacks dashboard fortune quote styling
  vim.api.nvim_set_hl(0, "SnacksDashboardFortune", { fg = "#f6c177", italic = true })
end

-- Apply custom highlights after any colorscheme change
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    -- Delay slightly to ensure colorscheme is fully loaded
    vim.defer_fn(function()
      -- Re-apply custom highlights (without calling colorscheme again to avoid loop)
      local normal_fg = "#e0def4"
      vim.api.nvim_set_hl(0, "Normal", { fg = normal_fg, bg = "none" })
      vim.api.nvim_set_hl(0, "NormalFloat", { fg = normal_fg, bg = "none" })
      vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
      vim.api.nvim_set_hl(0, "WinBar", { bg = "none" })
      vim.api.nvim_set_hl(0, "WinBarNC", { bg = "none", fg = "#6e7681" })
      vim.api.nvim_set_hl(0, "StatusLine", { bg = "none" })
      vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "none" })
      vim.api.nvim_set_hl(0, "ColorColumn", { bg = "#6e6a86" })
      vim.api.nvim_set_hl(0, "SnacksDashboardFortune", { fg = "#f6c177", italic = true })
      -- Diff highlights
      vim.api.nvim_set_hl(0, "DiffAdd", { bg = "#2b485a" })
      vim.api.nvim_set_hl(0, "DiffDelete", { bg = "#52313f" })
      vim.api.nvim_set_hl(0, "DiffChange", { bg = "#272d43" })
      vim.api.nvim_set_hl(0, "DiffText", { bg = "#394b70" })
      vim.api.nvim_set_hl(0, "DiffviewDiffAddAsDelete", { bg = "#52313f" })
      vim.api.nvim_set_hl(0, "DiffviewDiffDelete", { fg = "#6e6a86", bg = "none" })
    end, 10)
  end,
})

-- Run ColorMyPencils on startup
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    ColorMyPencils()
  end,
})

return {

    {
        "erikbackman/brightburn.vim",
    },

    {
        "folke/tokyonight.nvim",
        lazy = true, -- Not the active colorscheme
        config = function()
            require("tokyonight").setup({
                style = "storm",
                transparent = true,
                terminal_colors = true,
                styles = {
                    comments = { italic = false },
                    keywords = { italic = false },
                    sidebars = "dark",
                    floats = "dark",
                },
            })
        end
    },
    {
        "ellisonleao/gruvbox.nvim",
        name = "gruvbox",
        config = function()
            require("gruvbox").setup({
                terminal_colors = true, -- add neovim terminal colors
                undercurl = true,
                underline = false,
                bold = true,
                italic = {
                    strings = false,
                    emphasis = false,
                    comments = false,
                    operators = false,
                    folds = false,
                },
                strikethrough = true,
                invert_selection = false,
                invert_signs = false,
                invert_tabline = false,
                invert_intend_guides = false,
                inverse = true, -- invert background for search, diffs, statuslines and errors
                contrast = "", -- can be "hard", "soft" or empty string
                palette_overrides = {},
                overrides = {},
                dim_inactive = false,
                transparent_mode = false,
            })
        end,
    },

    {
        "rose-pine/neovim",
        name = "rose-pine",
        lazy = false,
        priority = 1000, -- Load before other plugins
        config = function()
            require('rose-pine').setup({
                disable_background = true,
                dim_inactive_windows = false,
                styles = {
                    italic = false,
                },
                groups = {
                    panel = "NONE", -- Transparent panels (fixes WinBarNC, NormalFloat, etc.)
                },
                highlight_groups = {
                    StatusLine = { fg = "subtle", bg = "NONE", inherit = false },
                    StatusLineNC = { fg = "muted", bg = "NONE", inherit = false },
                    WinBar = { fg = "subtle", bg = "NONE", inherit = false },
                    WinBarNC = { fg = "muted", bg = "NONE", inherit = false },
                },
            })

            ColorMyPencils();
        end
    },


}
