return {
  "mrcjkb/haskell-tools.nvim",
  version = "^3",
  ft = { "haskell", "lhaskell", "cabal", "cabalproject" },
  dependencies = {
    { "nvim-telescope/telescope.nvim", optional = true },
  },
  config = function()
    local ht = require("haskell-tools")
    local bufnr = vim.api.nvim_get_current_buf()
    local opts = { noremap = true, silent = true, buffer = bufnr }
    -- haskell-language-server relies heavily on codeLenses,
    -- so auto-refresh (see advanced configuration) is enabled by default
    vim.keymap.set("n", "<space>hl", vim.lsp.codelens.run, opts)
    -- Hoogle search for the type signature of the definition under the cursor
    vim.keymap.set("n", "<space>hs", ht.hoogle.hoogle_signature, opts)
    -- Evaluate all code snippets
    vim.keymap.set("n", "<space>ea", ht.lsp.buf_eval_all, opts)
    -- Toggle a GHCi repl for the current package
    vim.keymap.set("n", "<leader>hr", ht.repl.toggle, opts)
    -- Toggle a GHCi repl for the current buffer
    vim.keymap.set("n", "<leader>hf", function()
      ht.repl.toggle(vim.api.nvim_buf_get_name(0))
    end, opts)
    vim.keymap.set("n", "<leader>hq", ht.repl.quit, opts)

    local ok, telescope = pcall(require, "telescope")
    if ok then
      telescope.load_extension("ht")
    end
  end,
}
