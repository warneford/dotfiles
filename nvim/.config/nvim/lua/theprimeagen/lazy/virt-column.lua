return {
    "lukas-reineke/virt-column.nvim",
    opts = {
        char = "│",        -- Character to display (alternatives: "▕", "┃", "║")
        virtcolumn = "80", -- Column position(s) - can be "80,120" for multiple
        highlight = "VirtColumn", -- Highlight group to use
    },
    config = function(_, opts)
        require("virt-column").setup(opts)

        -- Set the color to match your rose-pine theme
        -- Options to try:
        -- Subtle: "#3a3a5a"
        -- Muted rose-pine: "#6e6a86"
        -- Very subtle: "#44415a"
        vim.api.nvim_set_hl(0, "VirtColumn", { fg = "#6e6a86" })
    end,
}
