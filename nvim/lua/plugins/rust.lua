return {
  {
    "mrcjkb/rustaceanvim",
    ft = { "rust" },
    opts = {},
    server = {
      settings = {
        ["rust-analyzer"] = {
          check = {
            command = "clippy",
            -- extraArgs = {
            -- },
            workspace = false,
          },
        },
      },
    },
    config = function(_, opts)
      local project_config = vim.g.project_config
      if project_config ~= nil and project_config.rust_analyzer ~= nil then
        opts.server = vim.tbl_deep_extend("force", opts.server, project_config.rust_analyzer)
      end

      vim.g.rustaceanvim = opts
    end,
  },
}