local Runner = require "nvim-test.runner"
local ts_parsers = require("nvim-treesitter.parsers")
local ts_utils = require("nvim-treesitter.ts_utils")
local utils = require "nvim-test.utils"
local ts = vim.treesitter

local fqn_query = [[
    ((stmt (exp_infix (exp_apply 
        (exp_name) @exp-name
        (#match? @exp-name "^(describe)")
        (exp_literal)  @test-name
    )
    ))
    @scope-root)
]]

local hspec = Runner:init({
  command = { "runhaskell" },
  file_pattern = "\\v(Spec)\\.hs$",
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

function hspec:find_nearest_test(filetype)
  local ts_query = ts.get_query(ts_parsers.ft_to_lang(filetype), "nvim-test")
  local result = {}
  if ts_query then
    local curnode = ts_utils.get_node_at_cursor()
    while curnode do
        for pattern, match, _ in ts_query:iter_matches(curnode, 0) do
            for id, node in pairs(match) do
                local name = ts_query.captures[id]
                if name == "test-name" then
                    local test_name = self:parse_testname(ts.query.get_node_text(node, 0))
                    local parse_testname_func = function (t_name)
                        return self:parse_testname(t_name)
                    end
                    local fqn = utils:get_fully_qualified_name(filetype, node, test_name, parse_testname_func, "/", fqn_query)
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

function hspec:parse_testname(name)
  return name:gsub("^[\"'`]", ""):gsub("[\"'`]$", "")
end

function hspec:build_test_args(args, tests)
  table.insert(args, "--match")
  table.insert(args, table.concat(tests, "/"))
end

return hspec
