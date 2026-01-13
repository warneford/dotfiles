return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  config = function()
    local wk = require("which-key")
    wk.setup({
      preset = "modern",
      delay = 300,
      defer = function(ctx)
        -- Disable in visual modes
        return ctx.mode == "v" or ctx.mode == "V" or ctx.mode == "\22"
      end,
    })

    -- Register group names so they show up in which-key
    wk.add({
      { "<leader>c", group = "[c]ode / terminal" },
      { "<leader>g", group = "[g]it" },
      { "<leader>h", group = "[h]arpoon" },
      { "<leader>o", group = "[o]tter / c[o]de chunk" },
      { "<leader>q", group = "[q]uarto" },
      { "<leader>qr", group = "[r]un" },
      { "<leader>r", group = "[r] R specific" },
      { "<leader>v", group = "[v]im" },
      { "<leader>z", group = "[z] animations" },
      { "<leader>zr", desc = "Make it rain animation" },
      { "<leader>zg", desc = "Game of life animation" },
      { "<leader>zs", desc = "Scramble animation" },
    })
  end,
}
