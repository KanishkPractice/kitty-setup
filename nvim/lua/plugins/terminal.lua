return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = { { "<C-\\>", desc = "Toggle terminal" } },
    opts = {
      open_mapping = [[<C-\>]],
      direction = "float",
      float_opts = { border = "curved" },
    },
  },
}
