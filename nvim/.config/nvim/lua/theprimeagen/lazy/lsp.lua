return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "stevearc/conform.nvim",
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-nvim-lsp-signature-help",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/nvim-cmp",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
        "j-hui/fidget.nvim",
    },

    config = function()
        local cmp = require('cmp')
        local cmp_lsp = require("cmp_nvim_lsp")
        local capabilities = vim.tbl_deep_extend(
            "force",
            {},
            vim.lsp.protocol.make_client_capabilities(),
            cmp_lsp.default_capabilities())

        require("fidget").setup({})

        -- Mason setup
        -- Note: checkhealth warnings about Go/Rust/PHP/etc are expected
        -- if you don't have those language runtimes installed.
        -- They're only needed to install tools written in those languages.
        require("mason").setup({
            -- Use Homebrew Python for pip (avoids venv issues)
            pip = {
                upgrade_pip = false,
            },
        })
        require("mason-lspconfig").setup({
            ensure_installed = {
                "lua_ls",        -- Lua (for Neovim config)
                "pyright",       -- Python
                "r_language_server",  -- R (installed globally via R package manager)
                "ts_ls",         -- JavaScript/TypeScript
                "yamlls",        -- YAML (for Quarto frontmatter)
            },
            handlers = {
                function(server_name) -- default handler (optional)
                    require("lspconfig")[server_name].setup {
                        capabilities = capabilities
                    }
                end,

                -- R Language Server with rich documentation
                -- Note: quarto files use otter.nvim for LSP features in code blocks
                ["r_language_server"] = function()
                    local lspconfig = require("lspconfig")
                    lspconfig.r_language_server.setup({
                        capabilities = capabilities,
                        cmd = { vim.fn.stdpath("data") .. "/mason/bin/r-languageserver" },
                        filetypes = { "r", "rmd", "rmarkdown" },
                        settings = {
                            r = {
                                lsp = {
                                    rich_documentation = true,
                                },
                            },
                        },
                    })
                end,

                -- Python (Pyright) with workspace analysis
                ["pyright"] = function()
                    local lspconfig = require("lspconfig")
                    lspconfig.pyright.setup({
                        capabilities = capabilities,
                        settings = {
                            python = {
                                analysis = {
                                    autoSearchPaths = true,
                                    useLibraryCodeForTypes = true,
                                    diagnosticMode = "workspace",
                                },
                            },
                        },
                    })
                end,

                ["lua_ls"] = function()
                    local lspconfig = require("lspconfig")
                    lspconfig.lua_ls.setup {
                        capabilities = capabilities,
                        settings = {
                            Lua = {
                                format = {
                                    enable = true,
                                    -- Put format options here
                                    -- NOTE: the value should be STRING!!
                                    defaultConfig = {
                                        indent_style = "space",
                                        indent_size = "2",
                                    }
                                },
                            }
                        }
                    }
                end,

                -- YAML Language Server for YAML files (e.g., _quarto.yml, CI configs)
                -- Note: Quarto frontmatter completion is handled by cmp-r
                ["yamlls"] = function()
                    local lspconfig = require("lspconfig")
                    lspconfig.yamlls.setup({
                        capabilities = capabilities,
                        filetypes = { "yaml" },
                        settings = {
                            yaml = {
                                schemaStore = {
                                    enable = true,
                                    url = "https://www.schemastore.org/api/json/catalog.json",
                                },
                                validate = true,
                                completion = true,
                                hover = true,
                            },
                        },
                    })
                end,
            }
        })

        local cmp_select = { behavior = cmp.SelectBehavior.Select }

        cmp.setup({
            snippet = {
                expand = function(args)
                    require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
                end,
            },
            window = {
                completion = cmp.config.window.bordered(),
                documentation = cmp.config.window.bordered(),
            },
            mapping = cmp.mapping.preset.insert({
                ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
                ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
                ['<C-y>'] = cmp.mapping.confirm({ select = true }),
                ["<C-Space>"] = cmp.mapping.complete(),
                ['<C-d>'] = cmp.mapping.scroll_docs(4),
                ['<C-u>'] = cmp.mapping.scroll_docs(-4),
            }),
            sources = cmp.config.sources({
                { name = 'otter' },  -- Otter for quarto/markdown code blocks
                { name = 'cmp_r' },  -- R.nvim completions + Quarto YAML frontmatter
                { name = 'nvim_lsp', group_index = 1 },  -- LSP first priority
                { name = 'nvim_lsp_signature_help', group_index = 1 },  -- Function signatures
                { name = 'luasnip', group_index = 1 },
                { name = 'path', group_index = 1 },
            }, {
                { name = "copilot", group_index = 2 },  -- AI suggestions second
                { name = 'buffer', group_index = 2 },
            })
        })

        vim.diagnostic.config({
            -- update_in_insert = true,
            float = {
                focusable = false,
                style = "minimal",
                border = "rounded",
                source = "always",
                header = "",
                prefix = "",
            },
        })
    end
}
