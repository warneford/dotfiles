-- nvim-treesitter configuration for main branch (2025 rewrite)
-- See: https://github.com/nvim-treesitter/nvim-treesitter/discussions/7927

-- Parsers to install on startup
local ensure_installed = {
    "vimdoc", "c", "lua", "bash",
    "r", "markdown", "markdown_inline", "yaml", "python",
    "latex", -- needed for quarto equations
    -- Uncomment if doing web development:
    -- "javascript", "typescript", "jsdoc",
}

-- Filetypes to disable treesitter highlighting (large files handled separately)
local highlight_disabled = { "html" }

return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        lazy = false,
        build = ":TSUpdate",
        config = function()
            -- Install parsers using TSInstall command (handles already installed gracefully)
            for _, lang in ipairs(ensure_installed) do
                local ok = pcall(vim.treesitter.language.add, lang)
                if not ok then
                    vim.cmd("TSInstall " .. lang)
                end
            end

            -- Register custom filetype for templ
            vim.treesitter.language.register("templ", "templ")

            -- Use bash parser for zsh (no dedicated zsh parser exists yet)
            vim.treesitter.language.register("bash", "zsh")

            -- Auto-enable treesitter features on FileType
            vim.api.nvim_create_autocmd("FileType", {
                group = vim.api.nvim_create_augroup("TreesitterSetup", { clear = true }),
                callback = function(args)
                    local buf = args.buf
                    local ft = vim.bo[buf].filetype

                    -- Skip disabled filetypes
                    if vim.tbl_contains(highlight_disabled, ft) then
                        return
                    end

                    -- Skip large files (> 100KB)
                    local max_filesize = 100 * 1024
                    local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
                    if ok and stats and stats.size > max_filesize then
                        vim.notify(
                            "File larger than 100KB, treesitter disabled for performance",
                            vim.log.levels.WARN,
                            { title = "Treesitter" }
                        )
                        return
                    end

                    -- Enable treesitter highlighting
                    pcall(vim.treesitter.start, buf)

                    -- Enable treesitter indentation (experimental)
                    vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

                    -- Enable additional vim regex highlighting for markdown
                    if ft == "markdown" then
                        vim.bo[buf].syntax = "on"
                    end
                end,
            })
        end,
    },

    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        branch = "main",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        config = function()
            -- Textobject keymaps (select mode)
            local select = require("nvim-treesitter.textobjects.select")
            local function map_select(key, capture)
                vim.keymap.set({ "x", "o" }, key, function()
                    select.select_textobject(capture, "textobjects")
                end, { desc = "Select " .. capture })
            end

            map_select("af", "@function.outer")
            map_select("if", "@function.inner")
            map_select("ac", "@class.outer")
            map_select("ic", "@class.inner")
            map_select("ab", "@block.outer")
            map_select("ib", "@block.inner")
            map_select("as", "@statement.outer")
            map_select("ap", "@parameter.outer")
            map_select("ip", "@parameter.inner")
        end,
    },

    {
        "nvim-treesitter/nvim-treesitter-context",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        config = function()
            require("treesitter-context").setup({
                enable = true,
                multiwindow = false,
                max_lines = 10,
                min_window_height = 0,
                line_numbers = true,
                multiline_threshold = 20,
                trim_scope = "outer",
                mode = "cursor",
                separator = nil,
                zindex = 20,
                on_attach = nil,
            })
        end,
    },
}
