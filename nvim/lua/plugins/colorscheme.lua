return {
  {
    "craftzdog/solarized-osaka.nvim",

    transparent = true,
    lazy = false,
    priority = 1000,
    opts = {},
  },

  -- add gruvbox
  { "ellisonleao/gruvbox.nvim" },

  -- add kastushika
  {
    "rebelot/kanagawa.nvim",
    config = {
      colors = {
        palette = {
          -- change all usages of these colors
          waveRed = "#30c5bb",
          autumnRed = "#39c5bb",
        },
      },
    },
  },

  -- Configure LazyVim to load gruvbox
  {
    "LazyVim/LazyVim",

    opts = {
      colorscheme = "kanagawa-wave",
    },
  },
}
