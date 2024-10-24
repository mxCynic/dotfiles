return {
  "lervag/vimtex",
  lazy = false, -- lazy-loading will disable inverse search
  config = function()
    vim.g.vimtex_mappings_disable = { ["n"] = { "K" } } -- disable `K` as it conflicts with LSP hover
    vim.g.vimtex_quickfix_method = vim.fn.executable("pplatex") == 1 and "pplatex" or "latexlog"
    vim.g.vimtex_view_general_viewer = "zathura"
    vim.g.vimtex_view_use_temp_file = "@pdf"
    vim.g.vimtex_compiler_latexmk = {
      -- aux_dir = "", -- 辅助文件目录，默认为空则使用与.tex文件相同的目录
      out_dir = "latex.out", -- 输出文件目录，默认为空则使用与.tex文件相同的目录
      callback = 1, -- 启用回调函数，用于自动重新编译等
      continuous = 1, -- 启用连续模式，即文件改变时自动重新编译
      executable = "latexmk", -- 指定使用的编译器命令
      -- hooks = {}, -- 额外的钩子函数列表，这里没有添加任何钩子
      options = { -- latexmk的编译选项列表
        "-pdfxe", -- 使用xelatex编译成PDF，支持中文等
        "-verbose", -- 输出详细信息
        "-g",
        "-file-line-error", -- 错误信息包含文件名和行号
        "-synctex=1", -- 启用Synctex支持，便于源代码和PDF间跳转
        "-interaction=nonstopmode", -- 遇到错误不中断编译过程
      },
    }
  end,
}
