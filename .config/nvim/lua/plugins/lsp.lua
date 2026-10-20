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

-- C#: prefer Roslyn, fall back to OmniSharp. Roslyn needs a newer .NET runtime (10 today)
-- than some machines have, so when Mason's install is missing borrow the server and the
-- runtime the VS Code C# extension downloaded for itself. Projects still build with the
-- machine's own SDK either way.
local function newest(paths, pattern)
  local best, best_v
  for _, p in ipairs(paths) do
    local v = vim.version.parse(p:match(pattern) or "", { strict = false })
    if v and (not best_v or v > best_v) then
      best, best_v = p, v
    end
  end
  return best
end

local function vscode_roslyn_cmd()
  local home = vim.uv.os_homedir()
  local dll = newest(
    vim.fn.glob(home .. "/.vscode/extensions/ms-dotnettools.csharp-*/.roslyn/Microsoft.CodeAnalysis.LanguageServer.dll", false, true),
    "csharp%-([%d.]+)"
  )
  if not dll then
    return nil
  end
  local win = vim.fn.has("win32") == 1
  local storage = win and vim.env.APPDATA .. "/Code/User/globalStorage" or home .. "/.config/Code/User/globalStorage"
  local dotnet = newest(
    vim.fn.glob(storage .. "/ms-dotnettools.vscode-dotnet-runtime/.dotnet/*/dotnet" .. (win and ".exe" or ""), false, true),
    "%.dotnet[/\\]([%d.]+)"
  ) or "dotnet" -- the extension didn't need its own runtime, so the system one is new enough
  return {
    dotnet,
    dll,
    "--stdio",
    "--logLevel=Information",
    "--extensionLogDirectory=" .. vim.fn.stdpath("log") .. "/roslyn",
  }
end

local csharp_ls = "omnisharp"
if vim.fn.executable("roslyn-language-server") == 1 then
  csharp_ls = "roslyn_ls" -- Mason's install; lspconfig's default cmd finds it
else
  local cmd = vscode_roslyn_cmd()
  if cmd then
    vim.lsp.config("roslyn_ls", { cmd = cmd })
    csharp_ls = "roslyn_ls"
  end
end

-- OmniSharp's semantic token legend is malformed (token names with spaces), which is what
-- got the server shut down before, so drop that capability and let treesitter highlight.
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
  csharp_ls, -- roslyn_ls or omnisharp (:MasonInstall omnisharp), picked above
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
