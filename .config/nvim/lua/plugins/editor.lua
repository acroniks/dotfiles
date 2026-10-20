-- lua/plugins/editor.lua
local map = vim.keymap.set

vim.pack.add({
  { src = "https://github.com/nvim-tree/nvim-tree.lua" },
  { src = "https://github.com/nvim-tree/nvim-web-devicons" },
  { src = "https://github.com/fouladi/toggle-overlength.nvim" },
  { src = "https://github.com/folke/which-key.nvim" },
  { src = "https://github.com/lewis6991/gitsigns.nvim" },
  { src = "https://github.com/echasnovski/mini.nvim" },
  { src = "https://github.com/mg979/vim-visual-multi" },
})

-- File explorer
require("nvim-tree").setup({
  hijack_cursor = true,
  view = { width = 30 },
})

map("n", "<leader>-", "<cmd>NvimTreeOpen .<CR>", { desc = "Open explorer at cwd" })
map("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle explorer" })

-- Overlength highlighting
require("toggle-overlength").setup({
  column_length = 121,
})

vim.cmd("ToggleHiOverLength")

-- which-key shows available keybindings
require("which-key").setup({})

-- Git signs in the gutter
require("gitsigns").setup({})

-- mini.nvim collection
require("mini.pairs").setup()
require("mini.surround").setup()
require("mini.comment").setup()
require("mini.statusline").setup()

-- Visual-block I / A: turn the block into vim-visual-multi cursors so the text is shown
-- on every line while typing (like VSCodeVim) instead of only after <Esc>
local function block_insert(key)
  return function()
    local feed = function(keys, flags)
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), flags, false)
    end
    if vim.fn.mode() ~= "\22" then
      return feed(key, "n")
    end
    local top, bot = vim.fn.line("v"), vim.fn.line(".")
    if top > bot then top, bot = bot, top end
    local left, right = vim.fn.virtcol("v"), vim.fn.virtcol(".")
    if left > right then left, right = right, left end
    local ragged = vim.fn.winsaveview().curswant == vim.v.maxcol -- block extended with $
    local col = key == "I" and left or right
    local insert = key == "I" and "i" or (ragged and "A" or "a")
    -- Rebuild a one-column block on the edited side, then make a cursor per line.
    -- "x" runs it (and vim-visual-multi's own queued keys) before insert mode starts.
    local down = bot > top and (bot - top) .. "j" or ""
    feed("<Esc>" .. top .. "G" .. col .. "|<C-v>" .. down .. "<Plug>(VM-Visual-Cursors)", "mx")
    feed(insert, "m")
  end
end

map("x", "I", block_insert("I"), { desc = "Block insert (live)" })
map("x", "A", block_insert("A"), { desc = "Block append (live)" })
