-- lua/plugins/terminal.lua
local map = vim.keymap.set

vim.pack.add({
  { src = "https://github.com/akinsho/toggleterm.nvim" },
})

require("toggleterm").setup({
  size = function(term)
    if term.direction == "vertical" then
      return math.floor(vim.o.columns * 0.4)
    end
    return 15
  end,
  open_mapping = [[<C-\>]], -- toggle the terminal from normal, insert and terminal mode
  direction = "horizontal",
  shade_terminals = true,
  persist_size = true,
  float_opts = { border = "rounded" },
})

map("n", "<leader>tt", "<cmd>ToggleTerm direction=horizontal<CR>", { desc = "Terminal (bottom)" })
map("n", "<leader>tv", "<cmd>ToggleTerm direction=vertical<CR>", { desc = "Terminal (side)" })
map("n", "<leader>tf", "<cmd>ToggleTerm direction=float<CR>", { desc = "Terminal (float)" })

-- Run the current file in the terminal, chosen by filetype
local runners = {
  python = "python3 %s",
  lua = "lua %s",
  javascript = "node %s",
  typescript = "npx tsx %s",
  sh = "bash %s",
  go = "go run %s",
  rust = "cargo run",
  c = "gcc %s -o /tmp/a.out && /tmp/a.out",
  cpp = "g++ -std=c++20 %s -o /tmp/a.out && /tmp/a.out",
}

local function run_file()
  local cmd = runners[vim.bo.filetype]
  if not cmd then
    vim.notify("No runner for filetype: " .. vim.bo.filetype, vim.log.levels.WARN)
    return
  end
  vim.cmd("update")
  local file = vim.fn.shellescape(vim.fn.expand("%:p"))
  require("toggleterm").exec(cmd:format(file), 1) -- terminal #1, opens it if hidden
end

map("n", "<leader>rr", run_file, { desc = "Run current file" })

-- Terminal-mode ergonomics
map("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })
map("t", "<C-h>", [[<C-\><C-n><C-w>h]], { desc = "Go to left window" })
map("t", "<C-j>", [[<C-\><C-n><C-w>j]], { desc = "Go to lower window" })
map("t", "<C-k>", [[<C-\><C-n><C-w>k]], { desc = "Go to upper window" })
map("t", "<C-l>", [[<C-\><C-n><C-w>l]], { desc = "Go to right window" })
