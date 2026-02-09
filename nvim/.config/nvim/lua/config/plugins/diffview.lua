return {
  "sindrets/diffview.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
  keys = {
    { "<leader>gd", "<cmd>DiffviewOpen<CR>", desc = "Git [d]iff view" },
    { "<leader>gh", "<cmd>DiffviewFileHistory %<CR>", desc = "Git file [h]istory" },
    { "<leader>gH", "<cmd>DiffviewFileHistory<CR>", desc = "Git repo [H]istory" },
    { "<leader>gx", "<cmd>DiffviewClose<CR>", desc = "Close diff / e[x]it" },
  },
  opts = {
    enhanced_diff_hl = true,
    view = {
      default = {
        layout = "diff2_horizontal",
        winbar_info = false,
      },
      merge_tool = {
        layout = "diff3_mixed",
        disable_diagnostics = true,
        winbar_info = true,
      },
      file_history = {
        layout = "diff2_horizontal",
      },
    },
    file_panel = {
      listing_style = "tree",
      win_config = {
        position = "left",
        width = 35,
      },
    },
  },
}
