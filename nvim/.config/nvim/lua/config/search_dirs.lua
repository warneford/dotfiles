-- Shared search directory configuration
-- Used by telescope and fzf-lua

local M = {}

-- Directories to search when in $HOME
M.dirs = {
	vim.fn.expand("~/dotfiles"),
	vim.fn.expand("~/projects"),
	vim.fn.expand("~/Octant Dropbox"),
}

-- Returns search paths based on current directory
-- In $HOME: returns curated dirs
-- Elsewhere: returns nil (use default cwd behavior)
function M.get_search_paths()
	local cwd = vim.fn.getcwd()
	local home = vim.fn.expand("$HOME")

	if cwd == home then
		-- Filter to only existing directories
		local existing = {}
		for _, dir in ipairs(M.dirs) do
			if vim.fn.isdirectory(dir) == 1 then
				table.insert(existing, dir)
			end
		end
		return existing
	end

	return nil -- Use default cwd
end

return M
