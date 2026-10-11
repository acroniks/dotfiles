--: Options -------------------------------------------------------------------
vim.o.number = true
vim.o.cursolerline = true
vim.o.wrap = true
vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = 2
vim.o.swapfile = false
vim.o.signcolumn = "yes"
vim.o.ignorecase = false
vim.o.smartident = true
vim.o.termguicolors = true
vim.opt.completeopt = { "menuone", "noselect", "popup" }
vim.o.mouse = 'a'
vim.o.clipboard = 'unnamedplus'

--: Leader --------------------------------------------------------------------
vim.g.mapleader = ' '
local map = vim.keymap.set
map('n', '<leader>o', ':update<CR> :source<CR>')

--: Colorscheme ---------------------------------------------------------------
vim.pack.add({
	{ src = "https://github.com/ellisonleao/gruvbox.nvim" }
})

vim.cmd("colorscheme grubbox")
