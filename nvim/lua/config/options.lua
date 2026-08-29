local opt = vim.opt

-- Line numbers
opt.number = true
opt.relativenumber = true

-- Tabs & Indentation
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true

-- Line wrapping
opt.wrap = false

-- Search settings
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = true

-- Appearance
opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"
opt.cursorline = true
opt.scrolloff = 8
opt.sidescrolloff = 8

-- Clipboard & History
opt.clipboard = "unnamedplus"
opt.undofile = true
opt.swapfile = false
opt.backup = false

-- Splits
opt.splitright = true
opt.splitbelow = true

-- Performance & responsiveness
opt.updatetime = 200
opt.timeoutlen = 300

-- Fix Neovim 0.12 upstream markdown treesitter range nil bug
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "markdown.mdx" },
  callback = function(args)
    pcall(vim.treesitter.stop, args.buf)
    vim.bo[args.buf].syntax = "markdown"
  end,
})
