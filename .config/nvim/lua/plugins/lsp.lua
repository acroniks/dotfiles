-- lua/plugins/lsp.lua
-- Uses the built-in vim.lsp.config / vim.lsp.enable. nvim-lspconfig only supplies the
-- default server configs (its lsp/*.lua files); blink.cmp registers completion
-- capabilities for every server automatically.
local map = vim.keymap.set

vim.pack.add({
  { src = "https://github.com/neovim/nvim-lspconfig" },
  { src = "https://github.com/williamboman/mason.nvim" },
  { src = "https://github.com/saghen/blink.lib" },
  { src = "https://github.com/saghen/blink.cmp" },
  { src = "https://github.com/rafamadriz/friendly-snippets" },
  { src = "https://github.com/Hoffs/omnisharp-extended-lsp.nvim" },
})

require("mason").setup({})

require("blink.cmp").setup({
  -- Rust matcher is built on install/update when cargo exists (config/pack.lua);
  -- otherwise fall back to Lua quietly instead of warning on every startup
  fuzzy = { implementation = "prefer_rust" },
  signature = { enabled = true },
  completion = {
    list = {
      selection = { preselect = false, auto_insert = true },
    },
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 500,
    },
    menu = {
      auto_show = true,
      draw = {
        treesitter = { "lsp" },
        columns = { { "kind_icon", "label", "label_description", gap = 1 }, { "kind" } },
      },
    },
  },
  keymap = {
    preset = "default",
    ["<C-j>"] = { "select_next", "fallback" },
    ["<C-k>"] = { "select_prev", "fallback" },
    ["<C-enter>"] = { "accept", "fallback" },
  },
})

-- Server-specific overrides (merged over nvim-lspconfig's defaults)
vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
})

-- OmniSharp instead of roslyn_ls: roslyn-language-server needs .NET 10, this works on .NET 8.
-- Its semantic token legend is malformed (token names with spaces), which is what got the
-- server shut down before, so drop that capability and let treesitter do highlighting.
vim.lsp.config("omnisharp", {
  on_init = function(client)
    client.server_capabilities.semanticTokensProvider = nil
  end,
  settings = {
    RoslynExtensionsOptions = {
      EnableImportCompletion = true,
    },
  },
})

-- Names must match the files in nvim-lspconfig's lsp/ directory
vim.lsp.enable({
  "lua_ls",
  "rust_analyzer",
  "omnisharp", -- C#; install with :MasonInstall omnisharp
  "ts_ls",
  "pyright",
  "gopls",
})

-- Diagnostics: show messages inline (off by default since Neovim 0.11)
vim.diagnostic.config({
  virtual_text = { spacing = 2, source = "if_many" },
  severity_sort = true,
  float = { border = "rounded", source = true },
})

-- LSP keybindings (set on attach). Neovim 0.12 already provides:
--   K hover, grn rename, gra code action, grr references, gri implementation,
--   grt type definition, grx run codelens, gO document symbols, <C-s> signature help (insert),
--   [d / ]d prev/next diagnostic, <C-w>d diagnostic float
-- Plain `gr` is deliberately not mapped: it would delay all of the gr* defaults above.
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(event)
    local tb = require("telescope.builtin")
    local function bmap(mode, lhs, rhs, desc)
      map(mode, lhs, rhs, { buffer = event.buf, desc = desc })
    end

    -- OmniSharp needs omnisharp-extended to follow these into metadata/decompiled sources
    local nav = {
      definitions = tb.lsp_definitions,
      references = tb.lsp_references,
      implementations = tb.lsp_implementations,
      type_definitions = tb.lsp_type_definitions,
    }
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client.name == "omnisharp" then
      local ox = require("omnisharp_extended")
      nav = {
        definitions = ox.telescope_lsp_definition,
        references = ox.telescope_lsp_references,
        implementations = ox.telescope_lsp_implementation,
        type_definitions = ox.telescope_lsp_type_definition,
      }
    end

    -- Navigation (Telescope pickers when there can be several results)
    bmap("n", "gd", nav.definitions, "Go to definition")
    bmap("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
    bmap("n", "grr", nav.references, "References")
    bmap("n", "<leader>gr", nav.references, "References")
    bmap("n", "gri", nav.implementations, "Implementations")
    bmap("n", "grt", nav.type_definitions, "Type definition")
    bmap("n", "<leader>ci", tb.lsp_incoming_calls, "Incoming calls")
    bmap("n", "<leader>co", tb.lsp_outgoing_calls, "Outgoing calls")

    -- Symbols
    bmap("n", "<leader>fs", tb.lsp_document_symbols, "Document symbols")
    bmap("n", "<leader>fS", tb.lsp_dynamic_workspace_symbols, "Workspace symbols")

    -- Editing
    bmap("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
    bmap({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
    -- <leader>lf (format) lives in plugins/format.lua so it works without an LSP too

    -- Diagnostics
    bmap("n", "<leader>d", vim.diagnostic.open_float, "Line diagnostics")
    bmap("n", "<leader>fd", function() tb.diagnostics({ bufnr = 0 }) end, "Buffer diagnostics")
    bmap("n", "<leader>fD", tb.diagnostics, "Workspace diagnostics")

    -- Toggles
    bmap("n", "<leader>th", function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }), { bufnr = event.buf })
    end, "Toggle inlay hints")
    bmap("n", "<leader>td", function()
      vim.diagnostic.enable(not vim.diagnostic.is_enabled({ bufnr = event.buf }), { bufnr = event.buf })
    end, "Toggle diagnostics")
  end,
})
