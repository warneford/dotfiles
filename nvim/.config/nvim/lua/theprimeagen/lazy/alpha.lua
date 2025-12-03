return {
    "goolord/alpha-nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VimEnter",
    config = function()
        local alpha = require("alpha")
        local dashboard = require("alpha.themes.dashboard")
        local fortune = require("alpha.fortune")

        -- Set header
        dashboard.section.header.val = {
            "                                                     ",
            "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ",
            "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ",
            "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ",
            "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ",
            "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ",
            "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ",
            "                                                     ",
        }

        -- Version string below header (right justified)
        local version = vim.version()
        local version_str = string.format("v%d.%d.%d", version.major, version.minor, version.patch)
        local header_width = 53 -- width of the ASCII art
        local padding = string.rep(" ", header_width - #version_str)
        dashboard.section.header.val[#dashboard.section.header.val + 1] = padding .. version_str

        -- Set menu
        dashboard.section.buttons.val = {
            dashboard.button("e", "  > New file", ":ene <BAR> startinsert <CR>"),
            dashboard.button("f", "  > Find file", ":Telescope find_files<CR>"),
            dashboard.button("r", "  > Recent", ":Telescope oldfiles<CR>"),
            dashboard.button("s", "  > Settings", ":e $MYVIMRC | :cd %:p:h<CR>"),
            dashboard.button("q", "  > Quit NVIM", ":qa<CR>"),
        }

        -- Random fortune/quote footer
        dashboard.section.footer.val = fortune()

        alpha.setup(dashboard.opts)

        -- Disable folding on alpha buffer
        vim.cmd([[autocmd FileType alpha setlocal nofoldenable]])
    end,
}
