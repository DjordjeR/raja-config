-- Basic Neovim options

-- Set line numbers to absolute and relative
vim.wo.number = true
vim.wo.relativenumber = true

-- Enable syntax highlighting
vim.cmd("syntax on")

-- Indentation
vim.o.expandtab = true
vim.o.shiftwidth = 4
vim.o.tabstop = 4

-- Other options
vim.o.wrap = false
vim.o.showmatch = true
vim.o.clipboard = "unnamedplus"

-- Enable termguicolors 
vim.o.termguicolors = true

-- Fixes my problem with zz screen centering
vim.o.lazyredraw = true

-- Add line at 80 char
vim.opt.colorcolumn = "80"

