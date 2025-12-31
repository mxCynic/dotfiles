-- Simple LSP configuration using Neovim's native LSP API
-- This is a simplified version for testing

-- Global LSP configuration
vim.lsp.config("*", {
  -- Common root markers for all servers
  root_markers = { ".git" },
})

-- Configure specific language servers
vim.lsp.config("lua_ls", {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = { { ".luarc.json", ".luarc.jsonc" }, ".git" },
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
      },
      workspace = {
        checkThirdParty = false,
        library = {
          vim.fn.expand("$VIMRUNTIME"),
        },
      },
      completion = {
        callSnippet = "Replace",
      },
      diagnostics = {
        globals = { "vim" },
      },
    },
  },
})

-- Enable LSP for Lua
vim.lsp.enable("lua_ls")

print("LSP configuration loaded successfully!")