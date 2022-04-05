---@diagnostic disable: unused-local
local utils = require "nvim-test.utils"
local ts_utils = require "nvim-treesitter.ts_utils"

local find_spec = function(filename)
  return filename
end

---@class Runner
local Runner = {
  config = {
    args = {},
    find_spec = find_spec,

    filename_modifier = nil,
    working_directory = nil,
  },
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

-- Build command list
---
---@return table cmd command list
function Runner:build_cmd(filename, opts)
  local args = utils.concat({}, self.config.args)
  self:build_args(args, filename, opts or {})
  table.insert(args, 1, self.config.command)
  return args
end

-- Build arguments
---
---@return table args arguments list
function Runner:build_args(args, filename, opts)
  if filename then
    table.insert(args, filename)
  end
  if opts.tests and #opts.tests > 0 then
    self:build_test_args(args, opts.tests)
  end
end

---@return table test_args test arguments list
function Runner:build_test_args(args, tests) end

return Runner
