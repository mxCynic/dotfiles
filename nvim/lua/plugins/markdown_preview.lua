return {
  "iamcco/markdown-preview.nvim",
  lazy = true,

  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  ft = { "markdown" },
  build = function()
    vim.fn["mkdp#util#install"]()
  end,

  config = {
    mkdp_echo_browser = "Chromium",
  },
}
