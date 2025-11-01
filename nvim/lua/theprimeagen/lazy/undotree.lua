
return {
    "mbbill/undotree",

    config = function()
        -- Configure undotree
        vim.g.undotree_SetFocusWhenToggle = 1
        vim.g.undotree_WindowLayout = 2

        -- Disable the problematic persistent undo autocmd
        vim.g.undotree_CustomUndotreeCmd = 'vertical 32 new'
        vim.g.undotree_CustomDiffpanelCmd = 'belowright 12 new'

        vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle, { desc = "Toggle Undotree" })
    end
}

