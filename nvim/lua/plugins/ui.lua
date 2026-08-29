return {
  -- Modern Statusline (Catppuccin Mocha)
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        theme = "catppuccin-mocha",
        component_separators = "|",
        section_separators = "",
      },
    },
  },

  -- Keybinding helper popup
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    opts = {},
  },

  -- Git status highlights in gutter
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {},
  },

  -- File tree explorer
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "Toggle Explorer" },
    },
    opts = {
      view = {
        width = 32,
      },
      renderer = {
        group_empty = true,
      },
    },
  },

  -- Animated smooth scrolling
  {
    "karb94/neoscroll.nvim",
    event = "VeryLazy",
    config = function()
      require("neoscroll").setup({
        mappings = { "<C-u>", "<C-d>", "<C-b>", "<C-f>", "<C-y>", "<C-e>", "zt", "zz", "zb" },
        hide_cursor = true,
        stop_eof = true,
        respect_scrolloff = false,
        cursor_scrolls_alone = true,
        easing_function = "quadratic",
      })
    end,
  },

  -- Animated smooth smear cursor motions
  {
    "sphamba/smear-cursor.nvim",
    event = "VeryLazy",
    opts = {
      cursor_color = "#f5e0dc",
      stiffness = 0.8,
      trailing_stiffness = 0.5,
      distance_stop_animating = 0.5,
      hide_target_hack = false,
    },
  },

  -- Buffer tabs at the top
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    keys = {
      { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev buffer" },
      { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
      { "<leader>bd", "<cmd>bdelete<cr>", desc = "Close buffer" },
      { "<leader>bo", "<cmd>BufferLineCloseOthers<cr>", desc = "Close other buffers" },
    },
    opts = {
      options = {
        diagnostics = "nvim_lsp",
        offsets = {
          { filetype = "NvimTree", text = "Explorer", highlight = "Directory", separator = true },
        },
      },
    },
  },

  -- Rainbow Indent Guides & Active Scope
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local highlight = {
        "RainbowRed",
        "RainbowYellow",
        "RainbowBlue",
        "RainbowOrange",
        "RainbowGreen",
        "RainbowViolet",
        "RainbowCyan",
      }

      local hooks = require("ibl.hooks")
      -- Create highlight groups from Catppuccin palette
      hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
        vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#f38ba8" })
        vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#f9e2af" })
        vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#89b4fa" })
        vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#fab387" })
        vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#a6e3a1" })
        vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#cba6f7" })
        vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#89dceb" })
      end)

      require("ibl").setup({
        indent = {
          char = "│",
          highlight = highlight,
        },
        scope = {
          enabled = true,
          show_start = true,
          show_end = false,
          highlight = highlight,
        },
      })
    end,
  },

  -- Oil.nvim: edit filesystem like a normal buffer
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "-", "<cmd>Oil<cr>", desc = "Open parent directory with Oil" },
    },
    opts = {
      default_file_explorer = false,
      columns = { "icon", "permissions", "size", "mtime" },
      view_options = {
        show_hidden = true,
      },
    },
  },

  -- Modern floating UI for cmdline, popups, and messages
  {
    "rcarriga/nvim-notify",
    opts = {
      background_colour = "#000000",
      timeout = 3000,
      render = "wrapped-compact",
    },
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = false,
        lsp_doc_border = true,
      },
    },
  },

  -- Smooth window resize & floating window animations (mini.animate)
  {
    "echasnovski/mini.animate",
    event = "VeryLazy",
    opts = function()
      local animate = require("mini.animate")
      return {
        resize = {
          enable = true,
          timing = animate.gen_timing.quadratic({ duration = 120, unit = "total" }),
        },
        open = {
          enable = true,
          timing = animate.gen_timing.quadratic({ duration = 100, unit = "total" }),
        },
        close = {
          enable = true,
          timing = animate.gen_timing.quadratic({ duration = 100, unit = "total" }),
        },
        -- Cursor & scroll animations handled by smear-cursor and neoscroll
        cursor = { enable = false },
        scroll = { enable = false },
      }
    end,
  },

  -- Fluid & beautiful inline diagnostic animation
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "LspAttach",
    priority = 1000,
    config = function()
      require("tiny-inline-diagnostic").setup({
        preset = "modern",
        options = {
          show_source = true,
          throttle = 20,
        },
      })
      vim.diagnostic.config({ virtual_text = false }) -- Disable default virtual text to avoid overlap
    end,
  },

  -- Code animation effects (rain, game of life)
  {
    "eandrju/cellular-automaton.nvim",
    cmd = "CellularAutomaton",
    keys = {
      { "<leader>mr", "<cmd>CellularAutomaton make_it_rain<cr>", desc = "Make it rain (Code Animation)" },
      { "<leader>mg", "<cmd>CellularAutomaton game_of_life<cr>", desc = "Game of Life (Code Animation)" },
    },
  },
}
