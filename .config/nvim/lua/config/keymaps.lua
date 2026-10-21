-- lua/config/keymaps.lua
local map = vim.keymap.set

-- Window navigation
map("n", "<leader><Tab>", "<C-w>w", { desc = "Next window" })
-- map("n", "<leader>h", "<C-w>h", { desc = "Go to left window" })
-- map("n", "<leader>j", "<C-w>j", { desc = "Go to lower window" })
-- map("n", "<leader>k", "<C-w>k", { desc = "Go to upper window" })
-- map("n", "<leader>l", "<C-w>l", { desc = "Go to right window" })
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- Window resizing (Alt + hjkl), also works from terminal mode
map({ "n", "t" }, "<A-h>", "<cmd>vertical resize -4<CR>", { desc = "Shrink width" })
map({ "n", "t" }, "<A-l>", "<cmd>vertical resize +4<CR>", { desc = "Grow width" })
map({ "n", "t" }, "<A-j>", "<cmd>resize -2<CR>", { desc = "Shrink height" })
map({ "n", "t" }, "<A-k>", "<cmd>resize +2<CR>", { desc = "Grow height" })
map("n", "<leader>=", "<C-w>=", { desc = "Equalize windows" })
map("n", "<leader>z", "<C-w>|<C-w>_", { desc = "Maximize window" })

-- Move lines
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up" })

-- Keep cursor centered when scrolling
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")

-- Clear search
map("n", "<Esc>", "<cmd>nohlsearch<CR>")
