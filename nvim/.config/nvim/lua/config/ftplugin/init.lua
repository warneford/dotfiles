-- Shared ftplugin utilities
local M = {}

-- Common wrapping settings for prose-like filetypes (markdown, quarto)
function M.setup_prose_wrapping()
    vim.wo.wrap = true
    vim.wo.linebreak = true
    vim.wo.breakindent = true
    vim.wo.showbreak = '|'
end

-- R console startup keymap (used in R and Quarto files)
function M.setup_r_keymaps()
    -- ,rb - Start R with bottom split layout (uses nvim terminal)
    -- R.nvim uses nvim's built-in terminal instead of tmux
    vim.keymap.set("n", "<localleader>rb", function()
        local config = require("r.config").get_config()
        config.rconsole_width = 0  -- 0 = horizontal split
        config.rconsole_height = math.floor(vim.o.lines / 3)
        require("r.run").start_R("R")
    end, { buffer = true, desc = "Start R (bottom split)" })
end

-- vim-slime cell delimiter for fenced code blocks
function M.setup_slime_cells()
    vim.b.slime_cell_delimiter = '```'
end

return M
