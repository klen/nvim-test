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

local tsmocha = Runner:init({
  command = { "./node_modules/.bin/ts-mocha", "ts-mocha" },
  file_pattern = "\\v(tests?/.*|test)\\.(ts|tsx)$",
  find_files = { "{name}.test.{ext}" },
}, {
  typescript = query,
})

function tsmocha:parse_testname(name)
  return name:gsub("^[\"'`]", ""):gsub("[\"'`]$", "")
end

function tsmocha:find_nearest_test(filetype)
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
                        return tsmocha:parse_testname(t_name)
                    end
                    local test_name = parse_testname_func(ts.query.get_node_text(node, 0))
                    local fqn = tsmocha:get_fully_qualified_name(filetype, node, test_name, parse_testname_func)
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

function tsmocha:get_fully_qualified_name(filetype, curnode, name, parse_testname_func)
    local ts_query = ts.query.parse_query(ts_parsers.ft_to_lang(filetype), query)
    local stop_index = curnode:start();
    curnode = curnode:parent()
    while curnode do
        local type = curnode:type()
        -- stop when we are at the root node
        -- typescript seems to have an extra node 'program'
        if type == "program" then
            return name
        end

        for _, match, _ in ts_query:iter_matches(curnode, 0, curnode:start(), stop_index) do
            for id, node in pairs(match) do
                local capture_name = ts_query.captures[id]
                if capture_name == "test-name" then
                    local test_name = parse_testname_func(ts.query.get_node_text(node, 0))
                    name = test_name .. " " .. name
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

function tsmocha:build_test_args(args, tests)
  table.insert(args, "-f")
  table.insert(args, table.concat(tests, " "))
end

return tsmocha
