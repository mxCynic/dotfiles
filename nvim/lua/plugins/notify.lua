return {
  {
    "folke/noice.nvim",
    init = function()
      vim.g.health = vim.tbl_extend("force", vim.g.health or {}, { style = "float" })
      local function center_health_float(buf)
        local win = vim.fn.bufwinid(buf)
        if win == -1 or not vim.api.nvim_win_is_valid(win) then
          return
        end
        local cfg = vim.api.nvim_win_get_config(win)
        if cfg.relative == "" then
          return
        end
        local width = vim.api.nvim_win_get_width(win)
        local height = vim.api.nvim_win_get_height(win)
        local row = math.max(0, math.floor((vim.o.lines - height) / 2) - 1)
        local col = math.max(0, math.floor((vim.o.columns - width) / 2))
        vim.api.nvim_win_set_config(win, {
          relative = "editor",
          row = row,
          col = col,
          width = width,
          height = height,
        })
      end

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "checkhealth",
        callback = function(event)
          vim.schedule(function()
            center_health_float(event.buf)
            vim.defer_fn(function()
              center_health_float(event.buf)
            end, 80)
          end)
        end,
      })
      vim.api.nvim_create_autocmd("VimEnter", {
        once = true,
        callback = function()
          pcall(vim.api.nvim_del_user_command, "LspInfo")
          vim.api.nvim_create_user_command("LspInfo", function()
            vim.cmd("checkhealth vim.lsp")
          end, {
            desc = "Show LSP info in a floating health window",
          })
        end,
      })
    end,
    opts = function(_, opts)
      opts.redirect = {
        view = "cmd_output_popup",
        filter = { event = "msg_show" },
      }

      opts.messages = opts.messages or {}
      opts.messages.enabled = true
      opts.routes = opts.routes or {}
      table.insert(opts.routes, 1, {
        view = "cmd_output_popup",
        filter = { event = "msg_show", cmdline = "^:%s*!" },
      })

      opts.presets = opts.presets or {}
      opts.presets.bottom_search = true
      opts.presets.command_palette = true
      opts.presets.long_message_to_split = true
      opts.presets.lsp_doc_border = true

      opts.views = opts.views or {}
      opts.views.cmd_output_popup = {
        view = "popup",
        enter = true,
        position = "50%",
        size = {
          width = "80%",
          height = "60%",
        },
        border = {
          style = "rounded",
        },
        close = {
          keys = { "q" },
        },
        win_options = {
          wrap = true,
        },
      }
      opts.views.cmdline_popup = {
        position = {
          row = "45%",
          col = "50%",
        },
        size = {
          width = 60,
          height = "auto",
        },
      }
    end,
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
  },
}
