return {
  {
    "jpalardy/vim-slime",
    init = function()
      vim.b["quarto_is_python_chunk"] = false
      Quarto_is_in_python_chunk = function()
        require("otter.tools.functions").is_otter_language_context("python")
      end

      -- Configure SLIME to work with IPython and R
      vim.cmd([[
      let g:slime_dispatch_ipython_pause = 100
      function SlimeOverride_EscapeText_quarto(text)
      call v:lua.Quarto_is_in_python_chunk()
      if exists('g:slime_python_ipython') && len(split(a:text,"\n")) > 1 && b:quarto_is_python_chunk && !(exists('b:quarto_is_r_mode') && b:quarto_is_r_mode)
      return ["%cpaste -q\n", g:slime_dispatch_ipython_pause, a:text, "--", "\n"]
      else
      if exists('b:quarto_is_r_mode') && b:quarto_is_r_mode && b:quarto_is_python_chunk
      return [a:text, "\n"]
      else
      return [a:text]
      end
      end
      endfunction
      ]])

      vim.g.slime_target = "tmux"
      vim.g.slime_no_mappings = true
      vim.g.slime_python_ipython = 1
      vim.g.slime_bracketed_paste = 1  -- Enable bracketed paste for multi-line R code
      -- Default tmux target (current window, right pane)
      vim.g.slime_default_config = {
        socket_name = "default",
        target_pane = "{right-of}",
      }
    end,
    config = function()
      vim.g.slime_input_pid = false
      vim.g.slime_suggest_default = true
      vim.g.slime_menu_config = false

      -- Configure slime target manually (no prompts)
      local function set_slime_target_manual()
        vim.fn.call("slime#config", {})
      end

      -- Auto-configure slime to right pane (.2)
      local function auto_config_slime()
        vim.b.slime_config = {
          socket_name = "default",
          target_pane = ":.2",
        }
        vim.notify("Slime configured to target pane :.2", vim.log.levels.INFO)
      end

      -- Send test message to verify connection
      local function test_slime()
        local config = vim.b.slime_config
        if config then
          vim.notify("Slime config: " .. vim.inspect(config), vim.log.levels.INFO)
          vim.fn["slime#send"]("# Test from Neovim\n")
        else
          vim.notify("No slime config set. Press <leader>ca to auto-configure.", vim.log.levels.WARN)
        end
      end

      -- Open zsh in nvim terminal below (hybrid approach: nvim terminal for shell, tmux for R)
      -- Use global to persist across buffer switches
      _G.zsh_term_jobid = nil
      _G.zsh_term_bufnr = nil

      local function open_zsh_terminal()
        -- Check if terminal buffer still exists
        if _G.zsh_term_bufnr and vim.api.nvim_buf_is_valid(_G.zsh_term_bufnr) then
          vim.notify("zsh terminal already open", vim.log.levels.INFO)
          return
        end

        -- Open new terminal below with basic zsh (skip p10k for simpler output)
        vim.cmd("belowright split | terminal POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true zsh --no-rcs -c 'source ~/.zshrc; exec zsh'")
        vim.cmd("resize 15")
        _G.zsh_term_jobid = vim.b.terminal_job_id
        _G.zsh_term_bufnr = vim.api.nvim_get_current_buf()
        vim.cmd("wincmd p") -- go back to previous window

        vim.notify("zsh terminal opened below", vim.log.levels.INFO)
      end

      local function send_to_zsh_terminal(text)
        if _G.zsh_term_jobid and vim.api.nvim_buf_is_valid(_G.zsh_term_bufnr or -1) then
          vim.api.nvim_chan_send(_G.zsh_term_jobid, text .. "\n")
        else
          vim.notify("No zsh terminal open. Press <leader>cz first.", vim.log.levels.WARN)
        end
      end

      -- Send current line to zsh terminal
      local function send_line_to_zsh()
        local line = vim.api.nvim_get_current_line()
        send_to_zsh_terminal(line)
      end

      -- Send visual selection to zsh terminal
      local function send_selection_to_zsh()
        -- Get visual selection
        local start_pos = vim.fn.getpos("'<")
        local end_pos = vim.fn.getpos("'>")
        local lines = vim.api.nvim_buf_get_lines(0, start_pos[2] - 1, end_pos[2], false)
        local text = table.concat(lines, "\n")
        send_to_zsh_terminal(text)
      end

      -- Keybindings
      vim.keymap.set("n", "<leader>cz", open_zsh_terminal, { desc = "open [z]sh in nvim terminal" })
      vim.keymap.set("n", "<leader>cl", send_line_to_zsh, { desc = "send [l]ine to zsh terminal" })
      vim.keymap.set("x", "<leader>cs", send_selection_to_zsh, { desc = "send [s]election to zsh terminal" })
      vim.keymap.set("n", "<leader>ca", auto_config_slime, { desc = "[a]uto-configure slime to right pane" })
      -- Generic REPL launcher (Python, Julia, etc. - NOT R, use ,rf for R)
      vim.keymap.set("n", "<leader>cp", function()
        vim.fn.system("tmux split-window -h -p 40 ipython")
        auto_config_slime()
      end, { desc = "open [p]ython console and configure slime" })
      vim.keymap.set("n", "<leader>ct", test_slime, { desc = "[t]est slime connection" })
    end,
  },
}
