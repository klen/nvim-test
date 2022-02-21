local Runner = require "nvim-test.runner"
local localCmd = vim.env.VIRTUAL_ENV .. "/bin/pytest"

local pytest = Runner:init {
  command = vim.fn.filereadable(localCmd) ~= 0 and localCmd or "pytest",
  queries = {
    python = [[
      ; Class
      ((class_definition
        name: (identifier) @class-name) @scope-root)

      ; Function
      ((function_definition
        name: (identifier) @function-name) @scope-root)
    ]],
  },
}

function pytest:is_test(name)
  return string.match(name, "[Tt]est") and true
end

function pytest:build_test_args(tests)
  return "::" .. table.concat(tests, "::")
end

return pytest
