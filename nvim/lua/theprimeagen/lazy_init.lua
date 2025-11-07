local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    spec = {
        -- Install luarocks.nvim first (required for plugins that need luarocks)
        {
            "vhyrro/luarocks.nvim",
            priority = 1000, -- Very high priority to load before other plugins
            config = true,
        },
        -- Load all other plugins from theprimeagen.lazy directory
        { import = "theprimeagen.lazy" },
    },
    change_detection = { notify = false },
    -- Disable lazy.nvim's built-in rocks support to avoid conflicts with luarocks.nvim
    rocks = {
        enabled = false,
    },
})
