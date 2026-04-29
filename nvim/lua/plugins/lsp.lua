return {
  -- Disable pyright since we use ty instead
  {
    "neovim/nvim-lspconfig",
    init = function()
      local function config_names_for_filetype(filetype)
        if vim.lsp.get_configs then
          local configs = vim.lsp.get_configs({ enabled = true, filetype = filetype })
          return vim.tbl_map(function(config)
            return config.name
          end, configs)
        end

        return {}
      end

      local function command_complete()
        local names = {}
        if vim.lsp.get_configs then
          for _, config in ipairs(vim.lsp.get_configs({ enabled = true })) do
            table.insert(names, config.name)
          end
        end
        table.sort(names)
        return names
      end

      local function current_buf_clients()
        return vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf() })
      end

      if vim.fn.exists(":LspInfo") == 0 then
        vim.api.nvim_create_user_command("LspInfo", function()
          local bufnr = vim.api.nvim_get_current_buf()
          local filetype = vim.bo[bufnr].filetype
          local bufname = vim.api.nvim_buf_get_name(bufnr)
          local clients = current_buf_clients()
          local lines = {
            "LSP info for current buffer",
            "",
            "Buffer: " .. (bufname ~= "" and vim.fn.fnamemodify(bufname, ":.") or "[No Name]"),
            "Filetype: " .. filetype,
            "",
            "Attached clients:",
          }

          if #clients == 0 then
            table.insert(lines, "  - none")
          else
            for _, client in ipairs(clients) do
              local root_dir = client.root_dir or "n/a"
              table.insert(lines, string.format("  - %s (id=%d, root=%s)", client.name, client.id, root_dir))
            end
          end

          table.insert(lines, "")
          table.insert(lines, "Enabled configs matching this filetype:")

          local matching_configs = config_names_for_filetype(filetype)
          if #matching_configs == 0 then
            table.insert(lines, "  - none")
          else
            for _, name in ipairs(matching_configs) do
              table.insert(lines, "  - " .. name)
            end
          end

          vim.cmd("new")
          local info_buf = vim.api.nvim_get_current_buf()
          vim.bo[info_buf].buftype = "nofile"
          vim.bo[info_buf].bufhidden = "wipe"
          vim.bo[info_buf].swapfile = false
          vim.bo[info_buf].modifiable = true
          vim.api.nvim_buf_set_name(info_buf, "LspInfo")
          vim.api.nvim_buf_set_lines(info_buf, 0, -1, false, lines)
          vim.bo[info_buf].modifiable = false
          vim.bo[info_buf].filetype = "markdown"
          vim.bo[info_buf].readonly = true
          vim.keymap.set("n", "q", "<cmd>close<cr>", {
            buffer = info_buf,
            silent = true,
            nowait = true,
            desc = "Close LspInfo",
          })
        end, {
          desc = "Show LSP clients for the current buffer",
        })
      end

      if vim.fn.exists(":LspStart") == 0 then
        vim.api.nvim_create_user_command("LspStart", function(opts)
          if opts.args ~= "" then
            vim.lsp.enable(opts.args, true)
            return
          end

          local filetype = vim.bo[vim.api.nvim_get_current_buf()].filetype
          local matching_configs = config_names_for_filetype(filetype)
          for _, name in ipairs(matching_configs) do
            vim.lsp.enable(name, true)
          end
        end, {
          desc = "Enable LSP configs",
          nargs = "?",
          complete = command_complete,
        })
      end

      if vim.fn.exists(":LspStop") == 0 then
        vim.api.nvim_create_user_command("LspStop", function(opts)
          if opts.args ~= "" then
            vim.lsp.enable(opts.args, false)
            return
          end

          for _, client in ipairs(current_buf_clients()) do
            client:stop()
          end
        end, {
          desc = "Stop LSP clients or disable a config",
          nargs = "?",
          complete = command_complete,
        })
      end

      if vim.fn.exists(":LspRestart") == 0 then
        vim.api.nvim_create_user_command("LspRestart", function(opts)
          if opts.args ~= "" then
            vim.lsp.enable(opts.args, false)
            vim.lsp.enable(opts.args, true)
            return
          end

          local restarted = {}
          for _, client in ipairs(current_buf_clients()) do
            if not restarted[client.name] then
              restarted[client.name] = true
              vim.lsp.enable(client.name, false)
              vim.lsp.enable(client.name, true)
            end
          end
        end, {
          desc = "Restart LSP clients or re-enable a config",
          nargs = "?",
          complete = command_complete,
        })
      end
    end,
    opts = {
      servers = {
        pyright = false,
      },
    },
  },
}
