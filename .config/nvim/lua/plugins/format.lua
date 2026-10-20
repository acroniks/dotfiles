-- lua/plugins/format.lua
-- conform.nvim runs a dedicated formatter per filetype and falls back to the LSP's
-- formatter when none is listed or none of the listed ones is installed.
-- Install formatters with Mason, e.g. :MasonInstall csharpier stylua
local map = vim.keymap.set

vim.pack.add({
  { src = "https://github.com/stevearc/conform.nvim" },
})

require("conform").setup({
  formatters_by_ft = {
    cs = { "csharpier" },
    lua = { "stylua" },
    rust = { "rustfmt" },
  },
  default_format_opts = { lsp_format = "fallback" },
})

-- Use conform for gq too
vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

map({ "n", "x" }, "<leader>lf", function()
  require("conform").format({ async = true })
end, { desc = "Format" })
