return {
  {
    "craftzdog/solarized-osaka.nvim",

    lazy = false,
    priority = 1000,
    opts = {},
  },

  -- add gruvbox
  { "ellisonleao/gruvbox.nvim" },

  -- Configure LazyVim to load gruvbox
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "solarized-osaka",
    },
  },
}
