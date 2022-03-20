---@diagnostic disable: unused-local
local ts_utils = require "nvim-treesitter.ts_utils"

local Runner = {
  config = { args = "" },
}
Runner.__index = Runner

function Runner:init(config, queries)
  self = setmetatable({}, Runner)
  self.queries = queries or {}
  self.config = vim.tbl_extend("force", self.config, config)
  for ft, query in pairs(self.queries) do
    vim.treesitter.set_query(ft, "nvim-test", query)
  end
  return self
end

function Runner:setup(config)
  if config then
    self.config = vim.tbl_deep_extend("force", self.config, config)
  end
  return self
end

function Runner:find_tests(filetype)
  local query = vim.treesitter.get_query(filetype, "nvim-test")
  local result = {}
  if query then
    local curnode = ts_utils.get_node_at_cursor()
    while curnode do
      local iter = query:iter_captures(curnode, 0)
      local capture_ID, capture_node = iter()
      if capture_node == curnode and query.captures[capture_ID] == "scope-root" then
        capture_ID, capture_node = iter()
        local name = self:parse_name(ts_utils.get_node_text(capture_node)[1])
        if self:is_test(name) then
          table.insert(result, 1, name)
        end
      end
      curnode = curnode:parent()
    end
  end
  return result
end

function Runner:parse_name(name)
  return name
end

function Runner:is_test(name)
  return true
end

function Runner:build_cmd(filename, opts)
  return string.format("%s%s", self.config.command, self:build_args(filename, opts or {}))
end

function Runner:build_args(filename, opts)
  local args = self.config.args
  if filename then
    args = args .. " " .. filename
  end
  if opts.tests and #opts.tests > 0 then
    args = args .. self:build_test_args(opts.tests)
  end
  return args
end

function Runner:build_test_args(tests)
  return ""
end

return Runner
