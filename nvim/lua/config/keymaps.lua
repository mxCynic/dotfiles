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
map("i", "<A-l>", "<Rig t>", { desc = "move left in insert mode" })

-- 切换inlay hint
if vim.lsp.buf.inlay_hint or vim.lsp.inlay_hint then
  map("n", "<leader>hi", function()
    LazyVim.toggle.inlay_hints()
  end, { desc = "Toggle Inlay Hints" })
end
