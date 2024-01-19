return {
  "nvim-orgmode/orgmode",
  dependencies = {
    { "nvim-treesitter/nvim-treesitter", lazy = true },
    { "akinsho/org-bullets.nvim", lazy = true },
  },
  event = "VeryLazy",
  config = function()
    -- Load treesitter grammar for org
    require("orgmode").setup_ts_grammar()

    -- Setup treesitter
    require("nvim-treesitter.configs").setup({
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = { "org" },
      },
      ensure_installed = { "org" },
    })

    -- Setup orgmode
    require("orgmode").setup({
      org_agenda_files = "~/orgfiles/**/*",
      org_default_notes_file = "~/orgfiles/refile.org",
      mappings = {
        org = {

          org_next_visible_heading = "<C-n>",
          org_previous_visible_heading = "<C-P>",
        },
      },
    })

    require("org-bullets").setup({
      concealcursor = false, -- If false then when the cursor is on a line underlying characters are visible
      symbols = {
        -- list symbol
        list = "•",
        -- headlines can be a list
        headlines = { "◉", "○", "✸", "✿" },
        -- or a function that receives the defaults and returns a list
        -- headlines = function(default_list)
        --   table.insert(default_list, "♥")
        --   return default_list
        -- end,
        checkboxes = {
          half = { "", "OrgTSCheckboxHalfChecked" },
          done = { "✓", "OrgDone" },
          todo = { "˟", "OrgTODO" },
        },
      },
    })
  end,
}
