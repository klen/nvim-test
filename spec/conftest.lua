-- Setup tests
--
-- Neovim 0.12 uses built-in treesitter. Parsers must be pre-installed as
-- shared libraries (.so files). The deprecated nvim-treesitter plugin is
-- not used here because its internal APIs are incompatible with 0.12.
--
-- For local development, install parsers via your plugin manager (e.g.
-- nvim-treesitter's :TSInstall, mason, or tree-sitter CLI).
--
-- For CI, ensure tree-sitter CLI is available and parsers are pre-built.

-- Make user-installed treesitter parsers available even in --clean mode
-- (which vusted uses by default and excludes ~/.local/share/nvim/site).
local xdg_data = os.getenv("XDG_DATA_HOME") or (os.getenv("HOME") .. "/.local/share")
local site_dir = xdg_data .. "/nvim/site"
if vim.fn.isdirectory(site_dir) == 1 then
  vim.o.runtimepath = site_dir .. "," .. vim.o.runtimepath
end

-- Register treesitter languages for filetypes that don't auto-match.
local register = vim.treesitter.language.register
if register then
  register("c_sharp", "cs")
end

return true
