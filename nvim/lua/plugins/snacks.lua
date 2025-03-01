return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
    bigfile = { enabled = true },
    dashboard = { enabled = false },
    explorer = { enabled = true },
    picker = {
      sources = {
        explorer = {
          auto_close = true,
          layout = { layout = { position = "float" } },
        },
      },
    },
    image = {
      enabled = true,
      doc = {
        enable = true,
        inline = true,
      },
    },
    notifier = { enabled = true },
    quickfile = { enabled = true },
    statuscolumn = { enabled = true },
    terminal = {
      win = {
        style = "terminal",
        position = "float",
      },
    },
    toggle = {
      map = vim.keymap.set, -- keymap.set function to use
      which_key = true, -- integrate with which-key to show enabled/disabled icons and colors
      notify = true, -- show a notification when toggling
      -- icons for enabled/disabled states
      icon = {
        enabled = " ",
        disabled = " ",
      },
      -- colors for enabled/disabled states
      color = {
        enabled = "green",
        disabled = "yellow",
      },
    },
    ui = {},
    words = { enabled = true },
  },
}
