return {
    "numToStr/Comment.nvim",
    config = function()
        require("Comment").setup({
            -- Add a space between comment and the line
            padding = true,
            -- Should comment out empty or whitespace only lines
            sticky = true,
            -- LHS of toggle mappings in NORMAL mode
            toggler = {
                line = 'gcc',  -- Line-comment toggle keymap
                block = 'gbc', -- Block-comment toggle keymap
            },
            -- LHS of operator-pending mappings in NORMAL and VISUAL mode
            opleader = {
                line = 'gc',   -- Line-comment keymap
                block = 'gb',  -- Block-comment keymap
            },
        })
    end,
}
