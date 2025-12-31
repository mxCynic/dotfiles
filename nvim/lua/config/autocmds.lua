-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

local function augroup(name)
  return vim.api.nvim_create_augroup("lazyvim_" .. name, { clear = true })
end

-- wrap and check for spell in text filetypes
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("wrap_spell"),
  pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = false
  end,
})

-- Fix TypeScript/TSX filetype detection
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  group = augroup("typescript_filetype"),
  pattern = { "*.tsx", "*.jsx" },
  callback = function()
    if vim.fn.expand("%:e") == "tsx" then
      vim.bo.filetype = "typescriptreact"
    elseif vim.fn.expand("%:e") == "jsx" then
      vim.bo.filetype = "javascriptreact"
    end
  end,
})

-- LSP progress updates on statusline
vim.api.nvim_create_autocmd("LspProgress", {
  group = augroup("lsp_progress"),
  callback = function()
    vim.cmd("redrawstatus")
  end,
})
