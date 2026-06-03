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

local function is_executable(path)
  return path and vim.fn.executable(path) == 1
end

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
          "/usr/share/hypr/stubs",
        },
      },
      completion = {
        callSnippet = "Replace",
      },
      diagnostics = {
        globals = { "vim", "hl" },
      },
    },
  },
})

-- Python
local python_root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" }
local python_lsp_server = nil
local ty_pythonpath = "/usr/lib/kitty"

if vim.env.PYTHONPATH and vim.env.PYTHONPATH ~= "" then
  ty_pythonpath = ty_pythonpath .. ":" .. vim.env.PYTHONPATH
end

if is_executable("ty") then
  vim.lsp.config("ty", {
    cmd = { "ty", "server" },
    cmd_env = { PYTHONPATH = ty_pythonpath },
    filetypes = { "python" },
    root_markers = python_root_markers,
    settings = {
      ty = {
        configuration = {
          strict = true,
          autoImportCompletions = true,
        },
      },
    },
  })
  python_lsp_server = "ty"
elseif is_executable("pyright-langserver") then
  vim.lsp.config("pyright", {
    cmd = { "pyright-langserver", "--stdio" },
    filetypes = { "python" },
    root_markers = python_root_markers,
    settings = {
      python = {
        analysis = {
          autoSearchPaths = true,
          diagnosticMode = "workspace",
          typeCheckingMode = "strict",
          useLibraryCodeForTypes = true,
        },
      },
    },
  })
  python_lsp_server = "pyright"
else
  vim.schedule(function()
    vim.notify("No Python LSP found: install `ty` or `pyright-langserver`.", vim.log.levels.WARN)
  end)
end

-- C/C++
vim.lsp.config("clangd", {
  cmd = { "clangd", "--background-index", "--clang-tidy", "--offset-encoding=utf-16" },
  filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
  root_markers = { ".clangd", "compile_commands.json", "compile_flags.txt", ".git" },
})

-- TypeScript/JavaScript
local js_ts_filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "typescript.tsx" }
local js_ts_root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" }

local function find_ts_server(root_dir)
  local local_vtsls = root_dir .. "/node_modules/.bin/vtsls"
  local local_ts_ls = root_dir .. "/node_modules/.bin/typescript-language-server"
  local candidates = {
    { name = "vtsls", path = local_vtsls, args = { "--stdio" } },
    {
      name = "ts_ls",
      path = local_ts_ls,
      args = { "--stdio" },
    },
  }

  for _, candidate in ipairs(candidates) do
    if is_executable(candidate.path) then
      return candidate.name, vim.list_extend({ candidate.path }, candidate.args)
    end
  end

  return nil, nil
end

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
-- vim.lsp.config("rust_analyzer", {
--   cmd = { "rust-analyzer" },
--   filetypes = { "rust" },
--   root_markers = { "Cargo.toml", "rust-project.json", ".git" },
--   settings = {
--     ["rust-analyzer"] = {
--       check = {
--         command = "clippy",
--         workspace = false,
--       },
--       cargo = {
--         allFeatures = true,
--         loadOutDirsFromCheck = true,
--       },
--       procMacro = {
--         enable = true,
--       },
--     },
--   },
-- })

-- Enable LSP servers
local servers_to_enable = {
  "lua_ls",
  "clangd",
  "hls",
  "texlab",
  -- Rust is managed by rustaceanvim. Enabling rust_analyzer here creates
  -- a second client that returns duplicate LSP locations.
}

if python_lsp_server then
  table.insert(servers_to_enable, python_lsp_server)
end

for _, server in ipairs(servers_to_enable) do
  vim.lsp.enable(server)
end

local function get_attached_clients(bufnr, excluded_client_id)
  return vim.tbl_filter(function(attached_client)
    return attached_client.id ~= excluded_client_id
  end, vim.lsp.get_clients({
    bufnr = bufnr,
    _uninitialized = true,
  }))
end

local function delete_augroup_if_exists(name)
  pcall(vim.api.nvim_del_augroup_by_name, name)
end

local function find_formatting_client(bufnr, excluded_client_id)
  for _, client in ipairs(get_attached_clients(bufnr, excluded_client_id)) do
    if not client:supports_method("textDocument/willSaveWaitUntil")
        and client:supports_method("textDocument/formatting") then
      return client
    end
  end
end

local function setup_format_on_save(bufnr, excluded_client_id)
  local group_name = "lsp_format_" .. bufnr
  local client = find_formatting_client(bufnr, excluded_client_id)
  if not client then
    delete_augroup_if_exists(group_name)
    return
  end

  vim.api.nvim_create_autocmd("BufWritePre", {
    group = vim.api.nvim_create_augroup(group_name, { clear = true }),
    buffer = bufnr,
    callback = function()
      if vim.bo[bufnr].filetype == "toml" then
        return
      end

      local active_client = find_formatting_client(bufnr)
      if not active_client then
        return
      end

      vim.lsp.buf.format({
        bufnr = bufnr,
        id = active_client.id,
        timeout_ms = 1000,
      })
    end,
  })
end

local function has_document_highlight_client(bufnr, excluded_client_id)
  for _, client in ipairs(get_attached_clients(bufnr, excluded_client_id)) do
    if client:supports_method("textDocument/documentHighlight") then
      return true
    end
  end

  return false
end

local function setup_document_highlight(bufnr, excluded_client_id)
  local highlight_group = "lsp_highlight_" .. bufnr
  local clear_group = "lsp_clear_highlight_" .. bufnr

  if not has_document_highlight_client(bufnr, excluded_client_id) then
    delete_augroup_if_exists(highlight_group)
    delete_augroup_if_exists(clear_group)
    vim.lsp.buf.clear_references()
    return
  end

  vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
    group = vim.api.nvim_create_augroup(highlight_group, { clear = true }),
    buffer = bufnr,
    callback = function()
      vim.lsp.buf.document_highlight()
    end,
  })

  vim.api.nvim_create_autocmd("CursorMoved", {
    group = vim.api.nvim_create_augroup(clear_group, { clear = true }),
    buffer = bufnr,
    callback = function()
      vim.lsp.buf.clear_references()
    end,
  })
end

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("js_ts_lsp_start", { clear = true }),
  pattern = js_ts_filetypes,
  callback = function(args)
    local root_dir = vim.fs.root(args.buf, js_ts_root_markers)
    if not root_dir then
      return
    end

    local server_name, cmd = find_ts_server(root_dir)
    if not server_name then
      vim.schedule(function()
        vim.notify(
          "No TypeScript LSP found for this project. Install @vtsls/language-server or typescript-language-server.",
          vim.log.levels.WARN
        )
      end)
      return
    end

    vim.lsp.start({
      name = server_name,
      cmd = cmd,
      root_dir = root_dir,
    }, {
      bufnr = args.buf,
      silent = true,
    })
  end,
})

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
      setup_format_on_save(args.buf)
    end

    -- Document highlight on cursor hold
    if client:supports_method("textDocument/documentHighlight") then
      setup_document_highlight(args.buf)
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

    -- Reconcile buffer-local LSP autocommands after this client detaches.
    setup_format_on_save(args.buf, client.id)
    setup_document_highlight(args.buf, client.id)
  end,
})
