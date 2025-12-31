-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- This file is automatically loaded by lazyvim.config.init
local Util = require("lazyvim.util")

-- DO NOT USE THIS IN YOU OWN CONFIG!!
-- use `vim.keymap.set` instead
local map = Util.safe_keymap_set

map({ "i", "n", "v" }, "<A-o>", "<esc>", { desc = "Esc" })
map("n", "<A-o>", ":noh<enter>", { desc = "Nohelight" })
map("n", "<leader>fl", ":Telescope builtin<enter>", { desc = "Telescope" })
map("n", "<leader>he", ":VimtexCompile<enter>", { desc = "toggle tex compile" })
map("n", "<leader>j", ":windo normal! j<enter>", { desc = "down in all windows" })
map("n", "<leader>k", ":windo normal! k<enter>", { desc = "up in all windows" })
map("n", "<A-n>", ":ObsidianToday<enter>", { desc = "up in all windows" })

map("i", "<A-h>", "<Left>", { desc = "move right in insert mode" })
map("i", "<A-j>", "<Down>", { desc = "move down in insert mode" })
map("i", "<A-k>", "<Up>", { desc = "move up in insert mode" })
map("i", "<A-l>", "<Right>", { desc = "move left in insert mode" })

map("n", "<leader><tab>h", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })
map("n", "<leader><tab>l", "<cmd>tabnext<cr>", { desc = "Next Tab" })

-- LSP keymaps (using Neovim's native LSP keymaps)
-- Note: Many LSP keymaps are now set globally by Neovim by default:
-- gra: code action, gri: implementation, grn: rename, grr: references
-- grt: type definition, gO: document symbol, K: hover
-- CTRL-S: signature help (insert mode), an/in: incremental selection

-- Additional LSP keymaps
map("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>", { desc = "Go to Definition" })
map("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<cr>", { desc = "Go to Declaration" })
map("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<cr>", { desc = "Go to Implementation" })
map("n", "gr", "<cmd>lua vim.lsp.buf.references()<cr>", { desc = "Go to References" })
map("n", "gt", "<cmd>lua vim.lsp.buf.type_definition()<cr>", { desc = "Go to Type Definition" })
map("n", "gs", "<cmd>lua vim.lsp.buf.document_symbol()<cr>", { desc = "Document Symbols" })
map("n", "gS", "<cmd>lua vim.lsp.buf.workspace_symbol()<cr>", { desc = "Workspace Symbols" })
map("n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<cr>", { desc = "Code Actions" })
map("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<cr>", { desc = "Rename" })
map("n", "<leader>fm", "<cmd>lua vim.lsp.buf.format()<cr>", { desc = "Format" })

-- Diagnostics keymaps
map("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<cr>", { desc = "Previous Diagnostic" })
map("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<cr>", { desc = "Next Diagnostic" })
map("n", "[e", "<cmd>lua vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })<cr>", { desc = "Previous Error" })
map("n", "]e", "<cmd>lua vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })<cr>", { desc = "Next Error" })
map("n", "<leader>xl", "<cmd>lua vim.diagnostic.setloclist()<cr>", { desc = "Location List Diagnostics" })
map("n", "<leader>xq", "<cmd>lua vim.diagnostic.setqflist()<cr>", { desc = "Quickfix Diagnostics" })
map("n", "<leader>xx", "<cmd>lua vim.diagnostic.open_float()<cr>", { desc = "Show Diagnostic" })

-- LSP workspace keymaps
map("n", "<leader>wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<cr>", { desc = "Add Workspace Folder" })
map("n", "<leader>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<cr>", { desc = "Remove Workspace Folder" })
map("n", "<leader>wl", "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<cr>", { desc = "List Workspace Folders" })

-- Inlay hints toggle
map("n", "<leader>th", "<cmd>lua vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 }))<cr>", { desc = "Toggle Inlay Hints" })
