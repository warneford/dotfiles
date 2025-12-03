vim.opt.guicursor = ""

vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

-- vim.opt.colorcolumn = "80"  -- Disabled: using virt-column.nvim instead

-- Python provider for neovim plugins (pynvim, image.nvim, etc.)
-- Uses dedicated venv to avoid conflicts with project venvs
vim.g.python3_host_prog = os.getenv("HOME") .. "/.local/share/nvim/python-env/bin/python"

-- Window title (shows in tmux status bar)
vim.opt.title = true
vim.opt.titlestring = "nvim %t"  -- Shows "nvim filename"

-- Force title update when switching buffers (for telescope, etc.)
vim.api.nvim_create_autocmd({ "BufEnter", "BufFilePost" }, {
    callback = function()
        local filename = vim.fn.expand("%:t")
        if filename ~= "" then
            vim.opt.titlestring = "nvim " .. filename
        else
            vim.opt.titlestring = "nvim"
        end
    end,
})

-- Netrw configuration (built-in file explorer)
vim.g.netrw_banner = 0        -- Hide banner
vim.g.netrw_liststyle = 3     -- Tree view
vim.g.netrw_browse_split = 4  -- Open in previous window
vim.g.netrw_winsize = 25      -- 25% width
vim.g.netrw_altv = 1          -- Split to the right

-- Toggle netrw with <leader>e (like neo-tree was)
vim.keymap.set("n", "<leader>e", ":Lexplore<CR>", { desc = "Toggle netrw", silent = true })
