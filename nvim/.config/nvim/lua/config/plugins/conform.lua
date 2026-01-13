return {
  "stevearc/conform.nvim",
  opts = {},
  config = function()
    require("conform").setup({
      format_on_save = function(bufnr)
        -- Use LSP formatting for filetypes that don't have dedicated formatters
        local lsp_format_ft = { "lua" } -- lua_ls has good built-in formatting
        local ft = vim.bo[bufnr].filetype
        return {
          timeout_ms = 5000,
          lsp_format = vim.tbl_contains(lsp_format_ft, ft) and "fallback" or "never",
        }
      end,
      formatters_by_ft = {
        lua = { "stylua" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        r = { "air" },
        rmd = { "injected" },
        quarto = { "injected" },
      },
      formatters = {
        injected = {
          options = {
            ignore_errors = true,
            lang_to_formatters = {
              r = { "air" },
              yaml = {},
            },
          },
        },
      },
    })

    vim.keymap.set("n", "<leader>f", function()
      require("conform").format({ bufnr = 0 })
    end)
  end,
}
