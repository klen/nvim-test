local Runner = require "nvim-test.runner"
local localCmd = "./node_modules/.bin/jest"

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
  command = vim.fn.filereadable(localCmd) ~= 0 and localCmd or "jest",
}, {
  typescript = query,
  javascript = query,
})

function jest:parse_name(name)
  return name:gsub("^[\"'`]", ""):gsub("[\"'`]$", "")
end

function jest:build_test_args(tests)
  return string.format(" -t '%s'", table.concat(tests, " "))
end

return jest
