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

-- Window title (shows in tmux status bar with filetype icon)
vim.opt.title = true

-- Filetype icons for tmux window name (Nerd Font icons)
local filetype_icons = {
    qmd = "⊕",                    -- Quarto (matching devicons.lua)
    r = "\xef\x81\xb4",           -- R: U+F074 (nf-fa-random, or use R logo)
    R = "\xef\x81\xb4",
    py = "\xee\x9c\xbc",          -- Python: U+E73C
    lua = "\xee\x98\xa0",         -- Lua: U+E620
    js = "\xee\x9e\x9c",          -- JavaScript: U+E79C (nf-md-language_javascript)
    ts = "\xee\x98\xa8",          -- TypeScript: U+E628
    json = "\xee\x98\x8b",        -- JSON: U+E60B
    md = "\xee\x9d\x8d",          -- Markdown: U+E74D
    sh = "\xee\xbc\x87",          -- Shell: U+EBC7
    zsh = "\xee\xbc\x87",
    bash = "\xee\xbc\x87",
    vim = "\xee\x98\xab",         -- Vim: U+E62B
    yml = "\xee\x98\xa0",         -- YAML: use generic
    yaml = "\xee\x98\xa0",
    toml = "\xee\x98\xa0",
    html = "\xee\x9e\xb6",        -- HTML: U+E7B6 (nf-md-language_html5)
    css = "\xee\x9e\x9e",         -- CSS: U+E79E (nf-md-language_css3)
    go = "\xee\x98\xa6",          -- Go: U+E626
    rs = "\xee\x9f\xa8",          -- Rust: U+E7A8
    default = "\xef\x8d\xaf",     -- Default: nvim icon U+F36F
}

-- Get icon for current file extension
local function get_filetype_icon()
    local ext = vim.fn.expand("%:e")
    return filetype_icons[ext] or filetype_icons.default
end

-- Helper to set tmux window name directly
local function set_tmux_window_name(name)
    if vim.env.TMUX then
        vim.fn.system("tmux rename-window " .. vim.fn.shellescape(name))
    end
end

-- Disable tmux automatic-rename so nvim can control the window name
if vim.env.TMUX then
    vim.fn.system("tmux set-window-option automatic-rename off")
end

-- Update tmux window name when switching buffers
vim.api.nvim_create_autocmd({ "BufEnter", "BufFilePost" }, {
    callback = function()
        local filename = vim.fn.expand("%:t")
        local icon = get_filetype_icon()
        if filename ~= "" then
            vim.opt.titlestring = icon .. " " .. filename
            set_tmux_window_name(icon .. " " .. filename)
        else
            vim.opt.titlestring = icon
            set_tmux_window_name(icon)
        end
    end,
})

-- Re-enable tmux automatic-rename when leaving nvim
vim.api.nvim_create_autocmd("VimLeavePre", {
    callback = function()
        if vim.env.TMUX then
            vim.fn.system("tmux set-window-option automatic-rename on")
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
