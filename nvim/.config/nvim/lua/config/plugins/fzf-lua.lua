local function smart_files(extensions)
    local search_dirs = require("config.search_dirs")
    local dirs = search_dirs.get_search_paths()

    -- Build extension flags if provided
    local ext_opts = ""
    if extensions and extensions ~= "" then
        for ext in extensions:gmatch("[^,]+") do
            ext = ext:match("^%s*(.-)%s*$") -- trim whitespace
            if ext ~= "" then
                ext_opts = ext_opts .. " -e " .. ext
            end
        end
    end

    -- Base fd_opts: search all files (--no-ignore) since <C-p> handles git-only
    local fd_opts = "--type f --hidden --no-ignore "
        .. "--exclude .git --exclude node_modules --exclude renv --exclude .venv --exclude __pycache__ --exclude .cache --exclude Library --exclude .dropbox"
        .. ext_opts

    if dirs then
        require("fzf-lua").files({ fd_opts = fd_opts, cwd = vim.env.HOME, search_paths = dirs })
    else
        require("fzf-lua").files({ fd_opts = fd_opts })
    end
end

local function smart_files_with_suffix()
    vim.ui.input({ prompt = "File extensions (comma-separated): " }, function(input)
        if input and input ~= "" then
            smart_files(input)
        end
    end)
end

local function smart_grep()
    local search_dirs = require("config.search_dirs")
    local dirs = search_dirs.get_search_paths()
    if dirs then
        require("fzf-lua").live_grep({ search_paths = dirs })
    else
        require("fzf-lua").live_grep()
    end
end

-- Grep for word under cursor
local function grep_cword()
    local word = vim.fn.expand("<cword>")
    local search_dirs = require("config.search_dirs")
    local dirs = search_dirs.get_search_paths()
    if dirs then
        require("fzf-lua").grep_cword({ search_paths = dirs })
    else
        require("fzf-lua").grep_cword()
    end
end

-- Grep for WORD under cursor
local function grep_cWORD()
    local search_dirs = require("config.search_dirs")
    local dirs = search_dirs.get_search_paths()
    if dirs then
        require("fzf-lua").grep_cWORD({ search_paths = dirs })
    else
        require("fzf-lua").grep_cWORD()
    end
end

return {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "FzfLua",
    keys = {
        -- File pickers (smart: curated dirs in $HOME, else cwd)
        { "<leader>ff", smart_files, desc = "Find files" },
        { "<leader>fx", smart_files_with_suffix, desc = "Find files by suffix" },
        { "<C-p>", "<cmd>FzfLua git_files<cr>", desc = "Git files" },
        -- Grep
        { "<leader>fg", smart_grep, desc = "Live grep" },
        { "<leader>fw", grep_cword, desc = "Grep word under cursor" },
        { "<leader>fW", grep_cWORD, desc = "Grep WORD under cursor" },
        -- Buffers & help
        { "<leader>fb", "<cmd>FzfLua buffers<cr>", desc = "Buffers" },
        { "<leader>fh", "<cmd>FzfLua help_tags<cr>", desc = "Help tags" },
        { "<leader>fr", "<cmd>FzfLua oldfiles<cr>", desc = "Recent files" },
        { "<leader>fc", "<cmd>FzfLua commands<cr>", desc = "Commands" },
        { "<leader>fk", "<cmd>FzfLua keymaps<cr>", desc = "Keymaps" },
        -- Git pickers
        { "<leader>fgs", "<cmd>FzfLua git_status<cr>", desc = "Git status" },
        { "<leader>fgc", "<cmd>FzfLua git_commits<cr>", desc = "Git commits" },
        { "<leader>fgb", "<cmd>FzfLua git_branches<cr>", desc = "Git branches" },
    },
    config = function()
        require("fzf-lua").setup({
            keymap = {
                builtin = {
                    ["<C-/>"] = "toggle-fullscreen",
                    ["<C-\\>"] = "toggle-preview",
                },
            },
            defaults = {
                file_icons = true,
                git_icons = true,
                color_icons = true,
                -- Show filename first, then path (icon always visible)
                formatter = "path.filename_first",
            },
            winopts = {
                height = 0.90,
                width = 0.90,
                preview = {
                    layout = "flex",
                    flip_columns = 120,
                    scrollbar = "float",
                    -- Larger preview for images
                    horizontal = "right:65%",
                    vertical = "down:60%",
                },
            },
            files = {
                fd_opts = "--type f --hidden --no-ignore --exclude .git --exclude node_modules --exclude renv --exclude .venv --exclude __pycache__ --exclude .cache --exclude Library --exclude .dropbox",
            },
            previewers = {
                builtin = {
                    -- Show path relative to cwd in preview title, truncate from left if too long
                    title_fnamemodify = function(s)
                        local cwd = vim.fn.getcwd()
                        -- Expand ~ to full path for comparison
                        local full_path = s:gsub("^~", vim.env.HOME)
                        -- Remove cwd prefix if present
                        if full_path:sub(1, #cwd) == cwd then
                            s = full_path:sub(#cwd + 2) -- +2 to skip the trailing /
                        else
                            -- Fallback: replace $HOME with ~
                            s = s:gsub("^" .. vim.env.HOME, "~")
                        end
                        -- Truncate from left if too long (keep ~60 chars)
                        local max_len = 60
                        if #s > max_len then
                            s = "…" .. s:sub(-(max_len - 1))
                        end
                        return s
                    end,
                    -- Use snacks.image for inline image rendering (kitty graphics protocol)
                    snacks_image = { enabled = true, render_inline = true },
                    extensions = {
                        ["png"] = { "builtin" },
                        ["jpg"] = { "builtin" },
                        ["jpeg"] = { "builtin" },
                        ["gif"] = { "builtin" },
                        ["webp"] = { "builtin" },
                    },
                },
            },
        })
    end,
}
