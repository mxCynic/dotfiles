return {
  -- Disable pyright since we use ty instead
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = false,
      },
    },
  },
}