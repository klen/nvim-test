local M = {}

---Get a text from the given treesitter node
---@return string s a text
function M.get_node_text(node, bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local start_row, start_col, _, end_col = node:range()
  local line = vim.api.nvim_buf_get_lines(bufnr, start_row, start_row + 1, false)[1]
  return line and string.sub(line, start_col + 1, end_col) or ""
end

function M.get_node_at_cursor()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local line = cursor[1] - 1
  local col = cursor[2]
  local parser = vim.treesitter.get_parser()
  if not parser then
    return
  end
  local lang_tree = parser:language_for_range { line, col, line, col }
  for _, tree in ipairs(lang_tree:trees()) do
    local root = tree:root()
    local node = root:named_descendant_for_range(line, col, line, col)
    if node then
      return node
    end
  end
end

---Concat tables
--
---@param r table a target table
---@param t table a table
---@return table r a target table
function M.concat(r, t)
  for _, value in ipairs(t) do
    table.insert(r, value)
  end
  return r
end

function M.check_executable(cmds)
  for _, cmd in ipairs(cmds) do
    if vim.fn.executable(cmd) == 1 then
      return cmd
    end
  end
  return cmds[#cmds]
end

---Find file by patterns
--
---@param source string
---@param patterns table
---@return string
function M.find_file_by_patterns(source, patterns, force)
  local ctx = {
    name = vim.fn.fnamemodify(source, ":t:r"),
    ext = vim.fn.fnamemodify(source, ":e"),
  }
  for _, pat in ipairs(patterns) do
    local filename = M.format_pattern(pat, ctx)
    local testfile = vim.fn.findfile(filename, source .. ";")
    if #testfile > 0 then
      return testfile
    end
    testfile = vim.fn.finddir(filename, source .. ";")
    if #testfile > 0 then
      return testfile
    end
  end
  if force then
    return vim.fn.fnamemodify(source, ":h") .. "/" .. M.format_pattern(patterns[1], ctx)
  end
  return source
end

---@param pattern string
---@return string
function M.format_pattern(pattern, ctx)
  local res = pattern
  for var in pattern:gmatch "{[^}]+}" do
    var = var:gsub("{", ""):gsub("}", "")
    res = res:gsub("{" .. var .. "}", ctx[var] or "")
  end
  return res
end

---Find the project root based on an indicating filename
---@param source string
---@param indicator string
---@return string
function M.find_relative_root(source, indicator)
  local path = vim.fn.findfile(indicator, vim.fn.fnamemodify(source, ":p") .. ";")
  if path and #path > 0 then
    path = vim.fn.fnamemodify(path, ":p:h")
  end
  return path
end

return M
