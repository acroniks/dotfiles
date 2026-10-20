-- lua/plugins/treesitter.lua
-- nvim-treesitter `main` branch: it only installs parsers/queries.
-- Highlighting and indent are turned on per buffer via the FileType autocmd below.

local can_build = require("config.pack").ts_can_build

vim.pack.add({
  { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
})

local parsers = {
  "lua", "cpp", "bash", "rust", "c_sharp", "python", "javascript",
  "json", "yaml", "toml", "html", "css",
  "markdown", "markdown_inline", "dockerfile",
}

-- No-op for parsers that are already installed
if can_build then
  require("nvim-treesitter").install(parsers)
else
  vim.notify("tree-sitter CLI or C compiler not found; skipping parser install", vim.log.levels.WARN)
end

vim.api.nvim_create_autocmd("FileType", {
  callback = function(ev)
    if not pcall(vim.treesitter.start, ev.buf) then
      return
    end
    -- Without an indents query (e.g. c_sharp) the treesitter indentexpr returns 0 for
    -- every line, so keep the filetype's own indent script instead
    local lang = vim.treesitter.language.get_lang(vim.bo[ev.buf].filetype)
    if lang and #vim.treesitter.query.get_files(lang, "indents") > 0 then
      vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})

-- Incremental selection, built on Neovim's own treesitter `an` / `in` visual mappings
vim.keymap.set("n", "<C-space>", "van", { remap = true, desc = "Start node selection" })
vim.keymap.set("x", "<C-space>", "an", { remap = true, desc = "Expand node selection" })
vim.keymap.set("x", "<bs>", "in", { remap = true, desc = "Shrink node selection" })
