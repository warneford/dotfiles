return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup({
        size = function(term)
          if term.direction == "horizontal" then
            return 15
          elseif term.direction == "vertical" then
            return vim.o.columns * 0.4
          end
        end,
        open_mapping = nil, -- We'll use custom mappings
        hide_numbers = true,
        shade_terminals = false,
        start_in_insert = true,
        insert_mappings = false,
        terminal_mappings = true,
        persist_size = true,
        persist_mode = true,
        direction = "horizontal",
        close_on_exit = true,
        shell = vim.o.shell,
        float_opts = {
          border = "curved",
          winblend = 0,
        },
      })

      local Terminal = require("toggleterm.terminal").Terminal

      -- Shell terminal (always available, count=2)
      -- Set NVIM_TERMINAL to skip MOTD display
      local shell_term = Terminal:new({
        cmd = "NVIM_TERMINAL=1 " .. vim.o.shell,
        count = 2,
        direction = "horizontal",
        display_name = "shell",
        on_open = function(term)
          vim.cmd("startinsert!")
          -- Set up terminal-mode mappings
          local opts = { buffer = term.bufnr, noremap = true, silent = true }
          vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
          vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
          vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
          vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
          vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], opts)
        end,
      })

      -- Python terminal (lazy, only created when needed, count=3)
      local python_term = nil

      local function get_python_term()
        if not python_term then
          python_term = Terminal:new({
            -- Use ipython-direnv wrapper to load project's Python environment
            cmd = "NVIM_TERMINAL=1 ipython-direnv",
            count = 3,
            direction = "horizontal",
            display_name = "python",
            on_open = function(term)
              vim.cmd("startinsert!")
              local opts = { buffer = term.bufnr, noremap = true, silent = true }
              vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
              vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
              vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
              vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
              vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], opts)
            end,
          })
        end
        return python_term
      end

      -- Helper to find R.nvim terminal window and buffer
      local function find_r_terminal()
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          local bufname = vim.api.nvim_buf_get_name(buf)
          if bufname:match("term://.*[Rr]adian") or bufname:match("term://.*:R$") then
            -- Find window if visible
            for _, win in ipairs(vim.api.nvim_list_wins()) do
              if vim.api.nvim_win_get_buf(win) == buf then
                return buf, win
              end
            end
            return buf, nil
          end
        end
        return nil, nil
      end

      -- Helper to hide all terminals (R, shell, python, quarto) without killing them
      local function hide_all_terminals()
        local _, r_win = find_r_terminal()
        if r_win then
          -- Just close the window, buffer stays alive
          pcall(vim.api.nvim_win_close, r_win, false)
        end
        -- toggleterm:close() hides the window but keeps the buffer/process alive
        if shell_term:is_open() then
          shell_term:close()
        end
        if python_term and python_term:is_open() then
          python_term:close()
        end
        if _G.toggleterm_quarto_term and _G.toggleterm_quarto_term:is_open() then
          _G.toggleterm_quarto_term:close()
        end
      end

      -- Helper to check which terminal is currently visible
      -- Returns: "shell", "python", "r", "quarto", or nil
      local function get_visible_terminal()
        if shell_term:is_open() then
          return "shell"
        end
        if python_term and python_term:is_open() then
          return "python"
        end
        local _, r_win = find_r_terminal()
        if r_win then
          return "r"
        end
        if _G.toggleterm_quarto_term and _G.toggleterm_quarto_term:is_open() then
          return "quarto"
        end
        return nil
      end

      -- Show a specific terminal (hides others first)
      local function show_terminal(which)
        hide_all_terminals()
        if which == "shell" then
          shell_term:open()
        elseif which == "python" and python_term then
          python_term:open()
        elseif which == "r" then
          local r_buf, _ = find_r_terminal()
          if r_buf then
            vim.cmd("botright split")
            vim.api.nvim_win_set_buf(0, r_buf)
            vim.cmd("resize " .. math.floor(vim.o.lines / 3))
            vim.cmd("startinsert")
          end
        elseif which == "quarto" and _G.toggleterm_quarto_term then
          _G.toggleterm_quarto_term:open()
        end
      end

      -- Cycle through available terminals: shell -> python (if init) -> R (if init) -> quarto (if init) -> shell ...
      local function cycle_terminals()
        local r_buf, _ = find_r_terminal()
        local has_python = python_term ~= nil
        local has_r = r_buf ~= nil
        local has_quarto = _G.toggleterm_quarto_term ~= nil
        local current = get_visible_terminal()

        -- Build list of available terminals
        local available = { "shell" }
        if has_python then
          table.insert(available, "python")
        end
        if has_r then
          table.insert(available, "r")
        end
        if has_quarto then
          table.insert(available, "quarto")
        end

        if current == nil then
          show_terminal(available[1])
        else
          for i, term in ipairs(available) do
            if term == current then
              local next_idx = (i % #available) + 1
              show_terminal(available[next_idx])
              return
            end
          end
          show_terminal(available[1])
        end
      end

      -- Direct toggle functions for specific terminals
      local function toggle_shell()
        if shell_term:is_open() then
          shell_term:close()
        else
          hide_all_terminals()
          shell_term:open()
        end
      end

      local function toggle_python()
        local term = get_python_term()
        if term:is_open() then
          term:close()
        else
          hide_all_terminals()
          term:open()
        end
      end

      local function toggle_r()
        local r_buf, r_win = find_r_terminal()
        if r_win then
          pcall(vim.api.nvim_win_close, r_win, false)
        elseif r_buf then
          hide_all_terminals()
          vim.cmd("botright split")
          vim.api.nvim_win_set_buf(0, r_buf)
          vim.cmd("resize " .. math.floor(vim.o.lines / 3))
          vim.cmd("startinsert")
        else
          vim.notify("R terminal not started. Use ,rf to start R.", vim.log.levels.WARN)
        end
      end

      -- Send code to shell terminal
      local function send_to_shell(code)
        if not shell_term:is_open() then
          hide_all_terminals()
          shell_term:open()
          -- Wait a bit for terminal to be ready
          vim.defer_fn(function()
            shell_term:send(code)
          end, 100)
        else
          shell_term:send(code)
        end
      end

      -- Send code to python terminal
      local function send_to_python(code)
        local term = get_python_term()
        if not term:is_open() then
          hide_all_terminals()
          term:open()
          -- Wait a bit for ipython to start
          vim.defer_fn(function()
            term:send(code)
          end, 500)
        else
          term:send(code)
        end
      end

      -- Expose functions globally for use by other modules
      _G.toggleterm_shell = {
        toggle = toggle_shell,
        send = send_to_shell,
        term = shell_term,
      }

      _G.toggleterm_python = {
        toggle = toggle_python,
        send = send_to_python,
        get_term = get_python_term,
      }

      _G.toggleterm_r = {
        toggle = toggle_r,
        find = find_r_terminal,
      }

      _G.toggleterm_cycle = cycle_terminals
      _G.toggleterm_hide_all = hide_all_terminals

      -- Open shell terminal alongside R when R starts
      -- This hooks into R.nvim's start event
      vim.api.nvim_create_autocmd("User", {
        pattern = "RStarted",
        callback = function()
          -- Small delay to let R terminal settle
          vim.defer_fn(function()
            if not shell_term:is_open() then
              shell_term:open()
              -- Return focus to editor
              vim.cmd("wincmd p")
            end
          end, 200)
        end,
      })

      -- Keep terminal buffers scrolled to the bottom
      local function scroll_terminal_to_bottom()
        local bufnr = vim.api.nvim_get_current_buf()
        if vim.bo[bufnr].buftype ~= "terminal" then
          return
        end
        local win = vim.api.nvim_get_current_win()
        local line_count = vim.api.nvim_buf_line_count(bufnr)
        local win_height = vim.api.nvim_win_get_height(win)
        -- Calculate topline so last line appears at bottom of window
        local topline = math.max(1, line_count - win_height + 1)
        vim.fn.winrestview({ topline = topline, lnum = line_count, col = 0 })
      end

      vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
        pattern = "term://*",
        callback = function()
          -- Only scroll if in normal mode (not terminal/insert mode)
          local mode = vim.fn.mode()
          if mode == "n" then
            vim.defer_fn(scroll_terminal_to_bottom, 10)
          end
        end,
      })

      -- Keybindings for terminal switching
      -- ,r2 - Cycle through terminals (shell -> python -> R -> close)
      vim.keymap.set("n", ",r2", cycle_terminals, { desc = "Cycle terminals (shell/python/R)" })
      vim.keymap.set("t", ",r2", [[<C-\><C-n><Cmd>lua _G.toggleterm_cycle()<CR>]], { desc = "Cycle terminals (shell/python/R)" })
      -- ,r3 - Toggle python terminal (lazy spawn, initializes python)
      vim.keymap.set("n", ",r3", toggle_python, { desc = "Toggle python terminal" })
      vim.keymap.set("t", ",r3", [[<C-\><C-n><Cmd>lua _G.toggleterm_python.toggle()<CR>]], { desc = "Toggle python terminal" })
      -- ,r4 - Toggle R terminal directly
      vim.keymap.set("n", ",r4", toggle_r, { desc = "Toggle R terminal" })
      vim.keymap.set("t", ",r4", [[<C-\><C-n><Cmd>lua _G.toggleterm_r.toggle()<CR>]], { desc = "Toggle R terminal" })

      -- Alternative: <C-\> based switching
      vim.keymap.set("n", "<C-\\>2", toggle_shell, { desc = "Toggle shell terminal" })
      vim.keymap.set("n", "<C-\\>3", toggle_python, { desc = "Toggle python terminal" })

      -- Quick toggle for shell (most common use case)
      vim.keymap.set("n", "<leader>ts", toggle_shell, { desc = "[t]oggle [s]hell terminal" })
      vim.keymap.set("n", "<leader>tp", toggle_python, { desc = "[t]oggle [p]ython terminal" })

      -- Terminal select (pick from list)
      vim.keymap.set("n", "<leader>tt", "<cmd>TermSelect<cr>", { desc = "[t]erminal select" })
    end,
  },
}
