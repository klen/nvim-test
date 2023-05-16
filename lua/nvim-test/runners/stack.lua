local Runner = require "nvim-test.runner"
local ts_parsers = require("nvim-treesitter.parsers")
local ts_utils = require("nvim-treesitter.ts_utils")
local ts = vim.treesitter

local stack = Runner:init({
  command = { "stack" },
  args = { "test" },
  find_files = { "{name}Spec.hs", "Spec.hs" },
}, {
  haskell = [[
      ((stmt (exp_infix (exp_apply 
          (exp_name) @exp-name
          (#match? @exp-name "^(describe|it)")
          (exp_literal)  @test-name
        )
      ))
      @scope-root)
    ]],
})

function stack:find_nearest_test(filetype)
  local ts_query = ts.get_query(ts_parsers.ft_to_lang(filetype), "nvim-test")
  local result = {}
  if ts_query then
    local curnode = ts_utils.get_node_at_cursor()
    while curnode do
        for pattern, match, _ in ts_query:iter_matches(curnode, 0) do
            for id, node in pairs(match) do
                local name = ts_query.captures[id]
                if name == "test-name" then
                    local test_name = stack:parse_testname(ts.query.get_node_text(node, 0))
                    local fqn = stack:get_fully_qualified_name(filetype, node, test_name)
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

function stack:get_fully_qualified_name(filetype, curnode, name)
    -- local ts_query = ts.get_query(ts_parsers.ft_to_lang(filetype), "nvim-test")
    local fqn_query = [[
      ((stmt (exp_infix (exp_apply 
          (exp_name) @exp-name
          (#match? @exp-name "^(describe)")
          (exp_literal)  @test-name
        )
      ))
      @scope-root)
    ]]
    local ts_query = ts.query.parse_query(ts_parsers.ft_to_lang(filetype), fqn_query)
    local stop_index = curnode:start();
    curnode = curnode:parent()
    while curnode do
        local type = curnode:type()
            for _, match, _ in ts_query:iter_matches(curnode, 0, curnode:start(), stop_index) do
                for id, node in pairs(match) do
                    local capture_name = ts_query.captures[id]
                    if capture_name == "test-name" then
                        local test_name = stack:parse_testname(ts.query.get_node_text(node, 0))
                        name = test_name .. "/" .. name
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

function stack:parse_testname(name)
  return name:gsub("^[\"'`]", ""):gsub("[\"'`]$", "")
end

function stack:build_test_args(args, tests)
  table.insert(
    args,
    "--test-arguments=" .. string.format("'--match \"%s\"'", table.concat(tests, "/"))
  )
end

return stack
