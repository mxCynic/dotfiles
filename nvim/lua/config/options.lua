-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.filetype.add({
  pattern = { [".*/hypr/.*conf"] = "hyprlang" },
})

-- 关闭保存时自动格式化
vim.g.autoformat = false
--   -- vim.filetype.add({
--   extension = {
--     tsx = "typescriptreact",
--   },
--   -- 强制将非标准的命名映射到标准命名
--   pattern = {
--     [".*%.tsx"] = "typescriptreact",
--     [".*/hypr/.*conf"] = "hyprlang",
--   },
-- })

-- Hyprlang LSP
-- vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
--   pattern = { "*/hypr/*.conf" },
--   callback = function(event)
--     print(string.format("starting hyprls for %s", vim.inspect(event)))
--     vim.lsp.start({
--       name = "hyprlang",
--       cmd = { "hyprls" },
--       root_dir = vim.fn.getcwd(),
--     })
--   end,
-- })
--
-- local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
