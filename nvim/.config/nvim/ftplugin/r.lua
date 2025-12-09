-- R-specific settings
-- This file is automatically loaded when opening .R files

local ft = require("config.ftplugin")

-- Use treesitter for indentation (== operator)
vim.bo.indentexpr = "nvim_treesitter#indent()"

-- R console keymaps
ft.setup_r_keymaps()
