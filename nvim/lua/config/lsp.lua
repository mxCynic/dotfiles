-- Modern LSP configuration using Neovim's native LSP API
-- Based on Neovim 0.11+ recommendations

-- Check if vim.lsp.config exists (requires Neovim 0.11+)
if not vim.lsp.config then
  vim.notify("LSP configuration requires Neovim 0.11+", vim.log.levels.ERROR)
  return
end

-- Global LSP configuration for all servers
vim.lsp.config("*", {
  -- Global capabilities for all LSP servers
  capabilities = {
    textDocument = {
      semanticTokens = {
        multilineTokenSupport = true,
      },
      completion = {
        completionItem = {
          snippetSupport = true,
          commitCharactersSupport = true,
          deprecatedSupport = true,
          preselectSupport = true,
          tagSupport = {
            valueSet = { 1 },
          },
          insertReplaceSupport = true,
          resolveSupport = {
            properties = {
              "documentation",
              "detail",
              "additionalTextEdits",
            },
          },
          insertTextModeSupport = {
            valueSet = { 1, 2 },
          },
        },
      },
    },
  },
  -- Common root markers for all servers
  root_markers = { ".git" },
})

-- Configure specific language servers

-- Lua
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

-- Python
vim.lsp.config("ty", {
  cmd = { "uvx", "ty", "server" },
  filetypes = { "python" },
  root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" },
  settings = {
    ty = {
      configuration = {
        strict = true,
        autoImportCompletions = true,
      },
    },
  },
})

-- C/C++
vim.lsp.config("clangd", {
  cmd = { "clangd", "--background-index", "--clang-tidy", "--offset-encoding=utf-16" },
  filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
  root_markers = { ".clangd", "compile_commands.json", "compile_flags.txt", ".git" },
})

-- TypeScript/JavaScript
vim.lsp.config("ts_ls", {
  cmd = { "typescript-language-server", "--stdio" },
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "typescript.tsx" },
  root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
})

-- Haskell
vim.lsp.config("hls", {
  cmd = { "haskell-language-server-wrapper", "--lsp" },
  filetypes = { "haskell", "lhaskell", "cabal" },
  root_markers = { "hie.yaml", "cabal.project", "*.cabal", "stack.yaml", ".git" },
})

-- LaTeX
vim.lsp.config("texlab", {
  cmd = { "texlab" },
  filetypes = { "tex", "plaintex", "bib" },
  root_markers = { ".git", ".latexmkrc", ".texlabroot" },
  settings = {
    texlab = {
      build = {
        args = { "-pdf", "-interaction=nonstopmode", "-synctex=1", "%f" },
        executable = "latexmk",
        onSave = false,
        forwardSearchAfter = false,
      },
      forwardSearch = {
        args = {},
        executable = "zathura",
      },
      chktex = {
        onOpenAndSave = false,
        onEdit = false,
      },
      diagnosticsDelay = 300,
      formatterLineLength = 80,
      latexindent = {
        modifyLineBreaks = false,
      },
    },
  },
})

-- Rust
vim.lsp.config("rust_analyzer", {
  cmd = { "rust-analyzer" },
  filetypes = { "rust" },
  root_markers = { "Cargo.toml", "rust-project.json", ".git" },
  settings = {
    ["rust-analyzer"] = {
      check = {
        command = "clippy",
        workspace = false,
      },
      cargo = {
        allFeatures = true,
        loadOutDirsFromCheck = true,
      },
      procMacro = {
        enable = true,
      },
    },
  },
})

-- Enable LSP servers
local servers_to_enable = {
  "lua_ls",
  "ty",
  "clangd",
  "ts_ls",
  "hls",
  "texlab",
  "rust_analyzer"
}

for _, server in ipairs(servers_to_enable) do
  vim.lsp.enable(server)
end

-- LSP attach handler for buffer-specific setup
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp_attach", { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then
      return
    end

    -- Enable completion if the server supports it
    if client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, args.buf, {
        autotrigger = false, -- Enable manually if desired
      })
    end

    -- Enable inlay hints if the server supports them
    if client:supports_method("textDocument/inlayHint") then
      vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
    end

    -- Auto-format on save if the server supports it and doesn't have willSaveWaitUntil
    if not client:supports_method("textDocument/willSaveWaitUntil") and
        client:supports_method("textDocument/formatting") then
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = vim.api.nvim_create_augroup("lsp_format_" .. args.buf, { clear = true }),
        buffer = args.buf,
        callback = function()
          vim.lsp.buf.format({
            bufnr = args.buf,
            id = client.id,
            timeout_ms = 1000,
          })
        end,
      })
    end

    -- Document highlight on cursor hold
    if client:supports_method("textDocument/documentHighlight") then
      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        group = vim.api.nvim_create_augroup("lsp_highlight_" .. args.buf, { clear = true }),
        buffer = args.buf,
        callback = function()
          vim.lsp.buf.document_highlight()
        end,
      })

      vim.api.nvim_create_autocmd("CursorMoved", {
        group = vim.api.nvim_create_augroup("lsp_clear_highlight_" .. args.buf, { clear = true }),
        buffer = args.buf,
        callback = function()
          vim.lsp.buf.clear_references()
        end,
      })
    end
  end,
})

-- LSP detach handler for cleanup
vim.api.nvim_create_autocmd("LspDetach", {
  group = vim.api.nvim_create_augroup("lsp_detach", { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then
      return
    end

    -- Clear autocommands related to this client/buffer
    vim.api.nvim_clear_autocmds({
      group = "lsp_format_" .. args.buf,
      buffer = args.buf,
    })
    vim.api.nvim_clear_autocmds({
      group = "lsp_highlight_" .. args.buf,
      buffer = args.buf,
    })
    vim.api.nvim_clear_autocmds({
      group = "lsp_clear_highlight_" .. args.buf,
      buffer = args.buf,
    })
  end,
})
