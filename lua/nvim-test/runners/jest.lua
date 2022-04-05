local Runner = require "nvim-test.runner"

local query = [[
  ((expression_statement
    (call_expression
      function: (identifier)
      arguments: (arguments [
        ((string) @method-name)
        ((template_string) @method-name)
      ]
    )))
  @scope-root)
]]

local jest = Runner:init({
  command = { "./node_modules/.bin/jest", "jest" },
  file_pattern = "\\v(__tests__/.*|(spec|test))\\.(js|jsx|coffee|ts|tsx)$",
  find_files = { "{name}.test.{ext}", "{name}.spec.{ext}" },
}, {
  javascript = query,
  typescript = query,
})

function jest:parse_testname(name)
  return name:gsub("^[\"'`]", ""):gsub("[\"'`]$", "")
end

function jest:build_test_args(args, tests)
  table.insert(args, "-t")
  table.insert(args, table.concat(tests, " "))
end

return jest
