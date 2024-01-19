return {
  "lukas-reineke/headlines.nvim",
  ft = {
    "markdown",
    "org",
  },
  config = function()
    local headline_highlights = {
      "HeadlineBlue",
      "HeadlineRed",
      "HeadlinePurple",
      "HeadlineRed",
    }
    vim.cmd([[highlight Headline1 guibg=#21262d]])
    vim.cmd([[highlight Headline2 guibg=#1e2718]])
    vim.cmd([[highlight CodeBlock guibg=#1c1c1c]])
    vim.cmd([[highlight Dash guibg=#D19A66 gui=bold]])

    require("headlines").setup({
      markdown = { headline_highlights = { "Headline1", "Headline2" } },
      org = { headline_highlights = { "Headline1", "Headline2" } },
    })
  end,
}
