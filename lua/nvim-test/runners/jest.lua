local Runner = require "nvim-test.runner"
local local_cmd = "./node_modules/.bin/jest"

local jest = Runner:init {
  command = vim.fn.filereadable(local_cmd) ~= 0 and local_cmd or "jest",
  queries = {
    javascript = [[
      ((expression_statement
        (call_expression
          function: (identifier)
          arguments: (arguments [
            ((string) @method-name)
            ((template_string) @method-name)
          ]
        )))
      @scope-root)
		]],
  },
}

function jest:parse_name(name)
  return name:gsub("^[\"'`]", ""):gsub("[\"'`]$", "")
end

function jest:build_test_args(tests)
  return string.format(" -t '%s'", table.concat(tests, " "))
end

return jest
