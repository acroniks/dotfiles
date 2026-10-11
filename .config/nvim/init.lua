--: Options -------------------------------------------------------------------
vim.o.number = true
vim.o.cursorline = true
vim.o.wrap = true
vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true
vim.o.swapfile = false
vim.o.signcolumn = "yes"
vim.o.ignorecase = false
vim.o.smartindent = true
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

require("gruvbox").setup({
  transparent_mode = true
})

vim.cmd("colorscheme gruvbox")

--: Autopairs -----------------------------------------------------------------
vim.pack.add({
  { src = "https://github.com/windwp/nvim-autopairs" }
})

require("nvim-autopairs").setup({})

--: Treesitter ----------------------------------------------------------------
vim.pack.add({
  { src = "https://github.com/nvim-treesitter/nvim-treesitter" }
})

require("nvim-treesitter").setup({
  ensure_installed = {
    "lua",
    "cpp",
    "bash",
    "rust",
    "cpp",
    "c_sharp",
    "javascript",
    "css"
  },
  auto_install = true
})

--: Nvimtree ------------------------------------------------------------------------------
vim.pack.add({
  { src = "https://github.com/nvim-tree/nvim-tree.lua" },
  { src = "https://github.com/nvim-tree/nvim-web-devicons" }
})

require("nvim-tree").setup({
  hijack_cursor = true,
  view = { width = 30}
})

map('n', '<leader>-', ':NvimTreeOpen .<CR>')

--: Overlength ----------------------------------------------------------------
vim.pack.add({
  { src = "https://github.com/fouladi/toggle-overlength.nvim" }
})

require("toggle-overlength").setup({
  column_length = 91
})

vim.cmd("ToggleHiOverLength")
