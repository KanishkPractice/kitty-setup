return {
  -- Auto close and rename HTML/JSX tags
  {
    "windwp/nvim-ts-autotag",
    event = { "BufReadPre", "BufNewFile" },
    opts = {},
  },

  -- Surround actions (ysaw", cs"', ds")
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    opts = {},
  },

  -- Real-time color highlighter & preview (#ffffff, rgb, hsl)
  {
    "brenoprata10/nvim-highlight-colors",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      render = "background",
      enable_named_colors = true,
      enable_tailwind = true,
    },
  },

  -- Comments support
  {
    "folke/ts-comments.nvim",
    event = "VeryLazy",
    opts = {},
  },
}
