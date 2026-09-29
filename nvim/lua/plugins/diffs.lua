return {
  {
    -- Treesitter-powered syntax highlighting for unified diffs.
    -- Note: diffs.nvim lazy-loads itself, so do not add `lazy`, `event`, `ft`,
    -- `keys`, or `config` to this spec (see :help diffs.nvim-setup).
    -- Upstream GitHub is retired on 2026-10-31, so we install from Forgejo.
    url = "https://forge.barrettruth.com/barrettruth/diffs.nvim",

    init = function()
      -- Read once, before the plugin loads.
      vim.g.diffs = {
        -- Additional filetypes to highlight. `diff` covers plain .diff/.patch
        -- buffers and other diff UIs (may overlap with diffview.nvim).
        -- extra_filetypes = { "diff" },
        -- integrations = { gitsigns = true },
      }
    end,
  },
}
