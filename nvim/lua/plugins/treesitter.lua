return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      highlight = {
        enable = true,
        disable = { "markdown", "markdown_inline" },
        additional_vim_regex_highlighting = { "markdown" },
      },
      indent = { enable = true },
      ensure_installed = {
        "lua",
        "vim",
        "vimdoc",
        "bash",
        "python",
        "javascript",
        "typescript",
        "json",
        "yaml",
        "toml",
        "dockerfile",
        "terraform",
        "hcl",
        "go",
        "rust",
        "sql",
        "html",
        "css",
        "regex",
      },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },
}
