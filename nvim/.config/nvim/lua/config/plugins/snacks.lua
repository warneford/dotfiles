-- Get a random programming quote
local function get_fortune()
	local fortune = require("config.fortune")
	return table.concat(fortune(), "\n")
end

return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		-- Image viewer with hover support
		image = {
			enabled = true,
			backend = "kitty",
			doc = {
				enabled = true,
				inline = true,
				float = true,
				max_width = 100,
				max_height = 12,
			},
		},

		-- Zen mode (replaces folke/zen-mode.nvim)
		zen = {
			enabled = true,
			toggles = {
				dim = true,
				git_signs = false,
				diagnostics = false,
			},
			show = {
				statusline = false,
				tabline = false,
			},
			win = {
				width = 90,
			},
		},

		-- Pretty notifications
		notifier = {
			enabled = true,
			timeout = 3000,
		},

		-- Disable heavy features on large files
		bigfile = {
			enabled = true,
			size = 1.5 * 1024 * 1024, -- 1.5MB
		},

		-- Highlight word under cursor + jump between occurrences
		words = {
			enabled = true,
		},

		-- Indent guide lines
		indent = {
			enabled = true,
			indent = {
				enabled = true,
				char = "│",
			},
			scope = {
				enabled = true,
				char = "│",
			},
		},

		-- Smooth scrolling
		scroll = {
			enabled = true,
			animate = {
				duration = { step = 10, total = 150 },
				easing = "inOutQuad",
			},
		},

		-- Dashboard (replaces alpha-nvim)
		dashboard = {
			enabled = true,
			preset = {
				header = [[

  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
]],
				keys = {
					{ icon = " ", key = "e", desc = "New file", action = ":ene | startinsert" },
					{ icon = " ", key = "f", desc = "Find file", action = ":FzfLua files" },
					{ icon = " ", key = "r", desc = "Recent", action = ":FzfLua oldfiles" },
					{ icon = " ", key = "g", desc = "Live grep", action = ":FzfLua live_grep" },
					{ icon = " ", key = "s", desc = "Settings", action = ":e $MYVIMRC | :cd %:p:h" },
					{ icon = " ", key = "q", desc = "Quit", action = ":qa" },
				},
			},
			sections = {
				{ section = "header" },
				{ section = "keys", gap = 1, padding = 1 },
				{
					text = { { get_fortune(), hl = "SnacksDashboardFortune" } },
					padding = 1,
					indent = 4,
					align = "center",
				},
				{ section = "startup" },
			},
		},
	},
	keys = {
		-- Zen mode toggles (matching your old keymaps)
		{
			"<leader>zz",
			function()
				Snacks.zen()
				vim.wo.wrap = false
				vim.wo.number = true
				vim.wo.rnu = true
			end,
			desc = "Toggle Zen Mode",
		},
		-- Image hover
		{
			"<leader>ih",
			function()
				Snacks.image.hover()
			end,
			desc = "Image hover preview",
		},
		-- Lazygit
		{
			"<leader>lg",
			function()
				Snacks.lazygit()
			end,
			desc = "Lazygit",
		},
		-- Jump between word occurrences
		{
			"]]",
			function()
				Snacks.words.jump(1, true)
			end,
			desc = "Next word occurrence",
			mode = { "n", "t" },
		},
		{
			"[[",
			function()
				Snacks.words.jump(-1, true)
			end,
			desc = "Prev word occurrence",
			mode = { "n", "t" },
		},
	},
}
