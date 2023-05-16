local Runner = require "nvim-test.runner"
local ts_parsers = require("nvim-treesitter.parsers")
local ts_utils = require("nvim-treesitter.ts_utils")
local utils = require "nvim-test.utils"
local ts = vim.treesitter

local query = [[
      (
        (call
          method: (identifier) @method-name
          (#match? @method-name "(describe|it|context)")
          arguments: (argument_list (string (string_content) @test-name))
        )
      @scope-root)
    ]]

local rspec = Runner:init({
  command = { "rspec", "bundle" },
  file_pattern = "\\v(spec_[^.]+|[^.]+_spec)\\.rb$",
  find_files = { "{name}_spec.rb" },
}, {
  ruby = query,
})

function rspec:find_working_directory(filename)
  local root = self.config.working_directory
  if not root then
    root = utils.find_relative_root(filename, "Gemfile")
  end
  return root
end

function rspec:build_args(args, filename, opts)
  if self.config.command == "bundle" then
    table.insert(args, "exec")
    table.insert(args, "rspec")
  end

  if filename then
    table.insert(args, filename)
  end
  if opts.tests and #opts.tests > 0 then
    self:build_test_args(args, opts.tests)
  end
end

function rspec:parse_testname(name)
  return name:gsub("^[\"'`]", ""):gsub("[\"'`]$", "")
end

function rspec:find_nearest_test(filetype)
  local ts_query = ts.get_query(ts_parsers.ft_to_lang(filetype), "nvim-test")
  local result = {}
  if ts_query then
    local curnode = ts_utils.get_node_at_cursor()
    while curnode do
        for pattern, match, _ in ts_query:iter_matches(curnode, 0) do
            for id, node in pairs(match) do
                local name = ts_query.captures[id]
                if name == "test-name" then
                    local test_name = rspec:parse_testname(ts.query.get_node_text(node, 0))
                    local parse_testname_func = function (t_name)
                        return rspec:parse_testname(t_name)
                    end
                    local fqn = utils:get_fully_qualified_name(filetype, node, test_name, parse_testname_func)
                    table.insert(result, fqn)
                    return result
                end
            end
        end
        curnode = curnode:parent()
    end
  end
  return result
end

function rspec:build_test_args(args, tests)
  table.insert(args, "--example")
  table.insert(args, "'" .. table.concat(tests, " ") .. "'")
end

return rspec
