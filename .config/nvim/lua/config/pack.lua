-- lua/config/pack.lua
-- Build hooks for vim.pack. These must be registered before the first vim.pack.add():
-- on a fresh machine vim.pack installs every plugin in nvim-pack-lock.json at that first call.
local M = {}

-- Compiling treesitter parsers needs the tree-sitter CLI and a C compiler; without them
-- Neovim's bundled parsers (lua, c, markdown, vim, ...) still work.
M.ts_can_build = vim.fn.executable("tree-sitter") == 1
  and vim.iter({ "cc", "gcc", "clang", "cl", "zig" }):any(function(c)
    return vim.fn.executable(c) == 1
  end)

local function build_fzf(cwd)
  -- Optional: telescope falls back to its built-in sorter if this can't be built
  if vim.fn.executable("make") == 1 then
    vim.system({ "make" }, { cwd = cwd }):wait()
  elseif vim.fn.executable("cmake") == 1 then
    vim.system({ "cmake", "-S.", "-Bbuild", "-DCMAKE_BUILD_TYPE=Release" }, { cwd = cwd }):wait()
    vim.system({ "cmake", "--build", "build", "--config", "Release" }, { cwd = cwd }):wait()
  else
    vim.notify("make/cmake not found; skipping telescope-fzf-native build", vim.log.levels.WARN)
  end
end

vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if kind ~= "install" and kind ~= "update" then
      return
    end

    if name == "telescope-fzf-native.nvim" then
      build_fzf(ev.data.path)
    elseif name == "nvim-treesitter" and M.ts_can_build then
      if not ev.data.active then
        vim.cmd.packadd("nvim-treesitter")
      end
      vim.cmd("TSUpdate")
    end
  end,
})

return M
