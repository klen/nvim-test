---@diagnostic disable: unused-local
local utils = require "nvim-test.utils"
local ts_utils = require "nvim-treesitter.ts_utils"
local ts_parsers = require "nvim-treesitter.parsers"
local ts = vim.treesitter

---@class Runner
local Runner = {
  config = {
    args = {},

    filename_modifier = nil,
    working_directory = nil,
  },
}
Runner.__index = Runner

function Runner:init(config, queries)
  self = setmetatable({}, Runner)
  self.queries = queries or {}
  for ft, query in pairs(self.queries) do
    local set_query = ts.query.set or ts.set_query  -- neovim 0.8 support
    set_query(ft, "nvim-test", query)
  end
  self:setup(config)
  return self
end

function Runner:setup(config)
  if config then
    self.config = vim.tbl_deep_extend("force", self.config, config)
  end
  if type(self.config.command) == "table" then
    self.config.command = utils.check_executable(self.config.command)
  end
  return self
end

function Runner:find_tests_in_file(filetype)
  return nil
end

function Runner:find_nearest_test(filetype)
  local query_get = ts.query.get or ts.get_query  -- neovim 0.8 support
  local query = query_get(ts_parsers.ft_to_lang(filetype), "nvim-test")
  local result = {}
  if query then
    local curnode = ts_utils.get_node_at_cursor()
    while curnode do
        for pattern, match, metadata in query:iter_matches(curnode, 0) do
            --print("pattern: " .. vim.inspect(pattern))
            --print("match: " .. vim.inspect(match))
            for id, node in pairs(match) do
                local name = query.captures[id]
                --print("capture: " .. name)
                if name == "test-name" then
                    local test_name = self:parse_testname(ts.query.get_node_text(node, 0))
                    --print("test name: " .. test_name)
                    local fqdn = self:get_fully_qualified_name(filetype, node, test_name)
                    table.insert(result, fqdn)
                    return result
                end
            end
        end
        curnode = curnode:parent()
    end
  end
  return result
end

---Check is the given filename is a test file
--
---@param filename string
---@return boolean
function Runner:is_testfile(filename)
  local file_pattern = self.config.file_pattern
  if file_pattern and #file_pattern > 0 then
    return vim.fn.match(filename, self.config.file_pattern) >= 0
  end
  return true
end

---Find a test file for the given filename
--
---@param filename string
---@return string
function Runner:find_file(filename, force)
  local finder = self.config.find_files
  if not finder then
    return filename
  end
  if type(finder) == "function" then
    return finder(filename)
  end
  if type(finder) == "string" then
    finder = { finder }
  end
  return utils.find_file_by_patterns(filename, finder, force)
end

---@param name string
---@return string
function Runner:parse_testname(name)
  return name
end

-- Find root directory
---@param filename string
---@return string
function Runner:find_working_directory(filename)
  return self.config.working_directory
end

---@param curnode tstree
---@param name string
---@return string
function Runner:get_fully_qualified_name(filetype, curnode, name)
    return name
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
