-- init.lua
-- Plugins are managed by the built-in vim.pack (see :h vim.pack).
-- Each lua/plugins/* module calls vim.pack.add() for what it needs, then configures it.

require("config.options") -- must come first: sets <leader>
require("config.keymaps")
require("config.pack") -- build hooks; must load before any vim.pack.add()

require("plugins.colorscheme")
require("plugins.editor")
require("plugins.treesitter")
require("plugins.telescope")
require("plugins.lsp")
require("plugins.format")
require("plugins.terminal")
