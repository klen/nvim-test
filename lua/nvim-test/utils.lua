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

return M
