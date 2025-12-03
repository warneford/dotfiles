return {
    "nvim-tree/nvim-web-devicons",
    config = function()
        require("nvim-web-devicons").setup({
            override_by_extension = {
                ["qmd"] = {
                    icon = "⊕",
                    color = "#75aadb",
                    name = "Quarto",
                },
            },
        })
    end,
}
