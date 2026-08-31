return {
  -- Lualine with powerline glyphs and theme styling
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function(_, opts)
      opts.options = {
        theme = "auto",
        globalstatus = true,
        disabled_filetypes = { statusline = { "dashboard", "alpha", "starter", "snacks_dashboard" } },
        section_separators = { left = "", right = "" },
        component_separators = { left = "", right = "" },
      }
    end,
  },

  -- Bufferline tab styling
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    opts = {
      options = {
        mode = "buffers",
        separator_style = "slant",
        always_show_bufferline = true,
        show_buffer_close_icons = true,
        show_close_icon = false,
        diagnostics = "nvim_lsp",
      },
    },
  },

  -- Custom Snacks Dashboard Header (Japanese Red Torii & Cyberpunk Art)
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = {
        preset = {
          header = [[
              ⛩️
        ███████████████████████████████████
            █                         █
            █  █████████████████████  █
            █  █                   █  █
            █  █   L A Z Y V I M   █  █
            █  █                   █  █
            █  █   K I T T Y  OS   █  █
            █  █                   █  █
               █                   █   
               █                   █   
          ]],
        },
      },
      scroll = { enabled = true },
      indent = { enabled = true },
      notifier = { enabled = true, timeout = 3000 },
      statuscolumn = { enabled = true },
      words = { enabled = true },
    },
  },
}
