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

--: Nvimtree -----------------------------------------------------------------------------
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

--: LSP ----------------------------------------------------------------------------------
vim.pack.add({
  { src = "https://github.com/neovim/nvim-lspconfig" },
  { src = "https://github.com/williamboman/mason.nvim" },
  { src = "https://github.com/saghen/blink.lib" },
  { src = "https://github.com/saghen/blink.cmp" },
  { src = "https://github.com/rafamadriz/friendly-snippets" }
})

vim.lsp.enable({
  "lua-language-server",
  "rust-analyzer"
})

require("mason").setup({})
require("blink.cmp").setup({
  fuzzy = { implementation = "prefer_rust_with_warning" },
  signature = { enabled = true },
  completion = {
    list = {
      selection = { preselect = false, auto_insert = true }
    },
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 500
    },
    menu = {
      auto_show = true,
      draw = {
        treesitter = { "lsp" },
        columns = { { "kind_icon", "label", "label_description", gap = 1 }, { "kind" } }
      }
    }
  },
  keymap = {
    preset = 'default',
    ['<C-j>'] = { 'select_next', 'fallback' },
    ['<C-k>'] = { 'select_prev', 'fallback' },
    ['<C-enter>'] = { 'accept', 'fallback' }
  }
})


--: Keybinds -----------------------------------------------------------------------------
map('n', '<leader>lf', vim.lsp.buf.format)
--map('n', '<leader>gd', vim.lsp.buf.definitions)
map('n', '<leader>gr', vim.lsp.buf.references)

map('n', '<leader><Tab>', '<c-w>w')
map('n', '<leader>h', '<c-w>h')
map('n', '<leader>j', '<c-w>j')
map('n', '<leader>k', '<c-w>k')
map('n', '<leader>l', '<c-w>l')
