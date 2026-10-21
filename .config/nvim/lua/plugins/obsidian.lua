-- lua/plugins/obsidian.lua
local map = vim.keymap.set

vim.pack.add({
  -- Pinned to the latest release; main's README often documents unreleased features
  { src = "https://github.com/obsidian-nvim/obsidian.nvim", version = vim.version.range("*") },
})

require("obsidian").setup({
  legacy_commands = false, -- use `:Obsidian <subcommand>` only (the default flips in 4.0.0)
  workspaces = {
    { name = "main", path = "~/Documents/notes/main" },
  },
  picker = { name = "telescope.nvim" },
  -- Completion for [[links]] and #tags is picked up by blink.cmp automatically
})

-- obsidian.nvim's link/checkbox rendering needs conceal
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.conceallevel = 2
  end,
})

map("n", "<leader>of", "<cmd>Obsidian quick_switch<cr>", { desc = "Find note" })
map("n", "<leader>og", "<cmd>Obsidian search<cr>", { desc = "Grep notes" })
map("n", "<leader>on", "<cmd>Obsidian new<cr>", { desc = "New note" })
map("n", "<leader>ob", "<cmd>Obsidian backlinks<cr>", { desc = "Backlinks" })
map("n", "<leader>ol", "<cmd>Obsidian links<cr>", { desc = "Links in note" })
map("n", "<leader>ot", "<cmd>Obsidian tags<cr>", { desc = "Tags" })
map("n", "<leader>ow", "<cmd>Obsidian workspace<cr>", { desc = "Switch vault" })
