return {
  -- LSP configuration
  {
    "neovim/nvim-lspconfig",
    opts = {
      diagnostics = {
        underline = true,
        update_in_insert = false,
        virtual_text = {
          spacing = 4,
          source = "if_many",
          prefix = "●",
        },
        severity_sort = true,
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = " ",
            [vim.diagnostic.severity.WARN] = " ",
            [vim.diagnostic.severity.HINT] = " ",
            [vim.diagnostic.severity.INFO] = " ",
          },
        },
      },
      servers = {
        bashls = {},
        cssls = {},
        dockerls = {},
        html = {},
        jsonls = {},
        lua_ls = {
          settings = {
            Lua = {
              workspace = {
                checkThirdParty = false,
              },
              completion = {
                callSnippet = "Replace",
              },
              diagnostics = {
                globals = { "vim", "Snacks" },
              },
            },
          },
        },
        marksman = {},
        pyright = {},
        ruff = {},
        vtsls = {},
        yamlls = {
          settings = {
            yaml = {
              schemas = {
                ["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "docker-compose*.{yml,yaml}",
              },
            },
          },
        },
      },
    },
  },

  -- Mason package manager
  {
    "mason-org/mason.nvim",
    opts = {
      ui = {
        border = "rounded",
      },
      ensure_installed = {
        "bash-language-server",
        "css-lsp",
        "dockerfile-language-server",
        "html-lsp",
        "json-lsp",
        "lua-language-server",
        "marksman",
        "prettierd",
        "pyright",
        "ruff",
        "shellcheck",
        "shfmt",
        "stylua",
        "vtsls",
        "yaml-language-server",
      },
    },
  },
}
