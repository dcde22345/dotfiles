return {
  -- disable render-markdown.nvim from LazyVim markdown extra
  { "MeanderingProgrammer/render-markdown.nvim", enabled = false },

  -- replace with markview.nvim
  {
    "OXY2DEV/markview.nvim",
    lazy = false,
    ft = { "markdown", "markdown.mdx" },
  },
}
