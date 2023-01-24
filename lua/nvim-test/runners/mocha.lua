local Runner = require "nvim-test.runner"
local ts_parsers = require("nvim-treesitter.parsers")
local ts_utils = require("nvim-treesitter.ts_utils")
local ts = vim.treesitter
local utils = require "nvim-test.utils"

local query = [[
  ((expression_statement
    (call_expression
      function: (identifier) @method-name
      (#match? @method-name "^(describe|test|it)")
      arguments: (arguments [
        (string (string_fragment) @test-name)
        ((template_string) @test-name)
      ]
    )))
  @scope-root)
]]

local mocha = Runner:init({
  command = { "./node_modules/.bin/mocha", "mocha" },
  -- args = { "mocha" },
  file_pattern = "\\v(tests?/.*|test)\\.(js|jsx|coffee)$",
  find_files = { "{name}.test.{ext}" },
}, {
  javascript = query,
  typescript = query,
})

function mocha:parse_testname(name)
  return name:gsub("^[\"'`]", ""):gsub("[\"'`]$", "")
end

function mocha:find_nearest_test(filetype)
  local ts_query = ts.get_query(ts_parsers.ft_to_lang(filetype), "nvim-test")
  local result = {}
  if ts_query then
    local curnode = ts_utils.get_node_at_cursor()
    while curnode do
        for pattern, match, _ in ts_query:iter_matches(curnode, 0) do
            for id, node in pairs(match) do
                local name = ts_query.captures[id]
                if name == "test-name" then
                    local parse_testname_func = function (t_name)
                        return mocha:parse_testname(t_name)
                    end
                    local test_name = parse_testname_func(ts.query.get_node_text(node, 0))
                    local fqdn = utils:get_fully_qualified_name(filetype, node, test_name, parse_testname_func)
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

function mocha:build_test_args(args, tests)
  table.insert(args, "-f")
  table.insert(args, table.concat(tests, " "))
end

return mocha
