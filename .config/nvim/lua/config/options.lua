-- lua/config/options.lua
local opt = vim.opt

vim.g.mapleader = " "
vim.g.maplocalleader = " "

opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.wrap = true
opt.scrolloff = 8
opt.sidescrolloff = 8

opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true

opt.ignorecase = false
opt.hlsearch = false
opt.incsearch = true

opt.splitright = true
opt.splitbelow = true
opt.termguicolors = true
opt.swapfile = false
opt.undofile = true
opt.updatetime = 250
opt.timeoutlen = 300

opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.completeopt = { "menuone", "noselect", "popup" }
