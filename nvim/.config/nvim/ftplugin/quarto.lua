-- Quarto-specific settings
-- This file is automatically loaded when opening .qmd files

local ft = require("config.ftplugin")

-- Prose wrapping and slime cell support
ft.setup_prose_wrapping()
ft.setup_slime_cells()

-- R console keymaps (Quarto often embeds R code)
-- Skip for .md files (e.g., quarto-generated markdown)
if vim.fn.expand("%:e") ~= "md" then
  ft.setup_r_keymaps()
end
