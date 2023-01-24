local ts_parsers = require("nvim-treesitter.parsers")
local ts = vim.treesitter

local M = {}

---Get a text from the given treesitter node
---@return string s a text
function M.get_node_text(node, bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local start_row, start_col, _, end_col = node:range()
  local line = vim.api.nvim_buf_get_lines(bufnr, start_row, start_row + 1, false)[1]
  return line and string.sub(line, start_col + 1, end_col) or ""
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

--- Find projects file directory by pattern
--
---@param proj_file_pattern string
---@param source string
---@return string
function M.find_proj_dir(proj_file_pattern, source)
  local is_proj_file = function (filename)
    local match = string.match(filename, proj_file_pattern)
    if match then
      return true
    end
    return false
  end
  local projfiles = vim.fs.find(is_proj_file, {
    path = source,
    upward = true,
    type = "file"
  })
  if projfiles and #projfiles > 0 then
    local dir = vim.fn.fnamemodify(projfiles[1], ":h")
    return dir
  end
  return source
end

--- Find fully qualified name of the test that is passed in name
---@param filetype any
---@param curnode any
---@param name any
---@param parse_testname_func any
---@param separator any
---@param query any
---@return any
function M:get_fully_qualified_name(filetype, curnode, name, parse_testname_func, separator, query)
    if separator == nil then
        separator = " "
    end

    local ts_query
    if query == nil then
        ts_query = ts.get_query(ts_parsers.ft_to_lang(filetype), "nvim-test")
    else

        ts_query = ts.query.parse_query(ts_parsers.ft_to_lang(filetype), query)
    end

    local stop_index = curnode:start();
    curnode = curnode:parent()
    while curnode do
        local type = curnode:type()
        print("ts type: " .. type)
            for _, match, _ in ts_query:iter_matches(curnode, 0, curnode:start(), stop_index) do
                for id, node in pairs(match) do
                    local capture_name = ts_query.captures[id]
                    print("capture_name: " .. capture_name)
                    if capture_name == "test-name" then
                        local test_name = parse_testname_func(ts.query.get_node_text(node, 0))
                        print("test_name: " .. test_name)
                        name = test_name .. separator .. name
                        break
                    end
                end

                if match ~= nil then
                    stop_index = curnode:start()
                end
                break -- break after the first match
            end
        curnode = curnode:parent()
    end
    return name
end


return M
