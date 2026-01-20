vim.g.mapleader = " "
vim.g.maplocalleader = ","
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.api.nvim_set_keymap("n", "<leader>tf", "<Plug>PlenaryTestFile", { noremap = false, silent = false })

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "=ap", "ma=ap'a")
vim.keymap.set("n", "<leader>zig", "<cmd>LspRestart<cr>")

vim.keymap.set("n", "<leader>vwm", function()
    require("vim-with-me").StartVimWithMe()
end)
vim.keymap.set("n", "<leader>svwm", function()
    require("vim-with-me").StopVimWithMe()
end)

-- greatest remap ever
vim.keymap.set("x", "<leader>p", [["_dP]])

-- next greatest remap ever : asbjornHaland
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

vim.keymap.set({ "n", "v" }, "<leader>d", "\"_d")

-- This is going to get me cancelled
vim.keymap.set("i", "<C-c>", "<Esc>")

vim.keymap.set("n", "Q", "<nop>")
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")
vim.keymap.set("n", "<M-h>", "<cmd>silent !tmux-sessionizer -s 0 --vsplit<CR>")
vim.keymap.set("n", "<M-H>", "<cmd>silent !tmux neww tmux-sessionizer -s 0<CR>")

-- Window navigation handled by vim-tmux-navigator plugin
-- This allows Ctrl+hjkl to work seamlessly between vim splits and tmux panes

-- Quickfix navigation
vim.keymap.set("n", "<leader>k", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>cprev<CR>zz")

vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

vim.keymap.set(
    "n",
    "<leader>ee",
    "oif err != nil {<CR>}<Esc>Oreturn err<Esc>"
)

vim.keymap.set(
    "n",
    "<leader>ea",
    "oassert.NoError(err, \"\")<Esc>F\";a"
)

vim.keymap.set(
    "n",
    "<leader>ef",
    "oif err != nil {<CR>}<Esc>Olog.Fatalf(\"error: %s\\n\", err.Error())<Esc>jj"
)

vim.keymap.set(
    "n",
    "<leader>el",
    "oif err != nil {<CR>}<Esc>O.logger.Error(\"error\", \"error\", err)<Esc>F.;i"
)

-- Cellular Automaton animations
vim.keymap.set("n", "<leader>zr", function()
    require("cellular-automaton").start_animation("make_it_rain")
end, { desc = "Make it rain animation" })

vim.keymap.set("n", "<leader>zg", function()
    require("cellular-automaton").start_animation("game_of_life")
end, { desc = "Game of life animation" })

vim.keymap.set("n", "<leader>zs", function()
    require("cellular-automaton").start_animation("scramble")
end, { desc = "Scramble animation" })

-- Reload current file if it's a vim config, otherwise reload init.lua
vim.keymap.set("n", "<leader><leader>", function()
    if vim.bo.filetype == "lua" and vim.fn.expand("%:p"):match("nvim") then
        vim.cmd("so")
    else
        vim.cmd("source $MYVIMRC")
    end
end)

-- Terminal mode: easier escape from terminal mode
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { desc = "exit terminal mode" })

-- Terminal mode: window navigation with Ctrl+hjkl (for radian, ipython, etc.)
vim.api.nvim_create_autocmd("TermOpen", {
    pattern = "*",
    callback = function()
        local opts = { buffer = 0, silent = true }
        vim.keymap.set("t", "<C-h>", [[<C-\><C-n><cmd>TmuxNavigateLeft<cr>]], opts)
        vim.keymap.set("t", "<C-j>", [[<C-\><C-n><cmd>TmuxNavigateDown<cr>]], opts)
        vim.keymap.set("t", "<C-k>", [[<C-\><C-n><cmd>TmuxNavigateUp<cr>]], opts)
        vim.keymap.set("t", "<C-l>", [[<C-\><C-n><cmd>TmuxNavigateRight<cr>]], opts)
    end,
})

