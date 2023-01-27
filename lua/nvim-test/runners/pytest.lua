local Runner = require "nvim-test.runner"
local utils = require "nvim-test.utils"
local ts_parsers = require("nvim-treesitter.parsers")
local ts_utils = require("nvim-treesitter.ts_utils")
local ts = vim.treesitter

local fqdn_query = [[
    (
        (
            class_definition name: (identifier) @test-name
            (#match? @test-name "[Tt]est")
        )
    @scope-root)
]]

local pytest = Runner:init({
  command = { (vim.env.VIRTUAL_ENV or "venv") .. "/bin/pytest", "pytest" },
  file_pattern = "\\v(test_[^.]+|[^.]+_test|tests)\\.py$",
  find_files = { "test_{name}.py", "{name}_test.py", "tests.py", "tests" },
}, {
  python = [[
      ; Class
      (
        (
          class_definition name: (identifier) @test-name
          (#match? @test-name "[Tt]est")
        )
      @scope-root)

      ; Function
      (
        (
          function_definition name: (identifier) @test-name
          (#match? @test-name "^[Tt]est")
        )
      @scope-root)
    ]],
})

function pytest:find_nearest_test(filetype)
  local ts_query = ts.get_query(ts_parsers.ft_to_lang(filetype), "nvim-test")
  local result = {}
  if ts_query then
    local curnode = ts_utils.get_node_at_cursor()
    while curnode do
        for pattern, match, _ in ts_query:iter_matches(curnode, 0) do
            for id, node in pairs(match) do
                local name = ts_query.captures[id]
                if name == "test-name" then
                    local test_name = pytest:parse_testname(ts.query.get_node_text(node, 0))
                    local parse_testname_func = function (t_name)
                        return pytest:parse_testname(t_name)
                    end
                    local fqdn = utils:get_fully_qualified_name(filetype, node, test_name, parse_testname_func, '::', fqdn_query)
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

function pytest:build_args(args, filename, opts)
  if filename then
    local path, _ = vim.fn.fnamemodify(filename, ":."):gsub("/", ".")
    table.insert(args, path)
  end
  if opts.tests and #opts.tests > 0 then
    args[#args] = args[#args] .. "::" .. table.concat(opts.tests, ".")
  end
end

return pytest
