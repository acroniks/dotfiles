-- lua/plugins/colorscheme.lua
vim.pack.add({
  { src = "https://github.com/ellisonleao/gruvbox.nvim" },
})

require("gruvbox").setup({
  transparent_mode = true,
})

vim.cmd.colorscheme("gruvbox")
