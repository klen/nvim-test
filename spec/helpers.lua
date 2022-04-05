-- local plugin_name = vim.split((...):gsub("%.", "/"), "/", true)[1]
local M = require "vusted.helper"

-- print(plugin_name, (...):gsub("%", "/"))
-- M.root = M.find_plugin_root(plugin_name)

function M.before_each(config)
  vim.cmd "filetype on"
  vim.cmd "syntax enable"
  require("nvim-test").setup(config or { run = false })
end

function M.after_each()
  -- vim.cmd "tabedit"
  -- vim.cmd "tabonly!"
  vim.cmd "silent %bwipeout!"
  vim.cmd "filetype off"
  vim.cmd "syntax off"
  M.cleanup_loaded_modules "nvim-test"
  print " "
end

function M.set_lines(lines)
  vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(lines, "\n"))
end

function M.input(text)
  vim.api.nvim_put({ text }, "c", true, true)
end

function M.edit(filename, line)
  local opts = line and string.format("+%s ", line) or ""
  vim.api.nvim_command(string.format("edit %s%s", opts, filename))
end

function M.view(filename, line)
  local opts = line and string.format("+%s ", line) or ""
  vim.api.nvim_command(string.format("view %s%s", opts, filename))
end

function M.debug(val)
  print(vim.inspect(val))
end

function M.search(pattern)
  local result = vim.fn.search(pattern)
  if result == 0 then
    local info = debug.getinfo(2)
    local pos = ("%s:%d"):format(info.source, info.currentline)
    local lines = table.concat(vim.fn.getbufline("%", 1, "$"), "\n")
    local msg = ("on %s: `%s` not found in buffer:\n%s"):format(pos, pattern, lines)
    assert(false, msg)
  end
  return result
end

local asserts = require("vusted.assert").asserts

asserts.create("filetype"):register_eq(function()
  return vim.bo.filetype
end)

asserts.create("buffer"):register_eq(function()
  return vim.api.nvim_buf_get_name(0)
end)

asserts.create("bufnr"):register_eq(function()
  return vim.api.nvim_get_current_buf()
end)

asserts.create("window"):register_eq(function()
  return vim.api.nvim_get_current_win()
end)

asserts.create("tab_count"):register_eq(function()
  return vim.fn.tabpagenr "$"
end)

asserts.create("window_count"):register_eq(function()
  return vim.fn.tabpagewinnr(vim.fn.tabpagenr(), "$")
end)

asserts.create("current_line"):register_eq(function()
  return vim.fn.getline "."
end)

asserts.create("current_col"):register_eq(function()
  return vim.fn.col "."
end)

asserts.create("current_row"):register_eq(function()
  return vim.fn.line "."
end)

asserts.create("current_word"):register_eq(function()
  return vim.fn.expand "<cword>"
end)

asserts.create("exists_pattern"):register(function(self)
  return function(_, args)
    local pattern = args[1]
    pattern = pattern:gsub("\n", "\\n")
    local result = vim.fn.search(pattern, "n")
    self:set_positive(("`%s` not found"):format(pattern))
    self:set_negative(("`%s` found"):format(pattern))
    return result ~= 0
  end
end)

asserts.create("exists_message"):register(function(self)
  return function(_, args)
    local expected = args[1]
    self:set_positive(("`%s` not found message"):format(expected))
    self:set_negative(("`%s` found message"):format(expected))
    local messages = vim.split(vim.api.nvim_exec("messages", true), "\n")
    for _, msg in ipairs(messages) do
      if msg:match(expected) then
        return true
      end
    end
    return false
  end
end)

return M
