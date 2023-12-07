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

  -- Configure LazyVim to load gruvbox
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "solarized-osaka",
    },
  },
}
