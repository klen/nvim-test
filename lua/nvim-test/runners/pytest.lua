local Runner = require "nvim-test.runner"

local cmd = "pytest"
if vim.env.VIRTUAL_ENV and vim.fn.filereadable(vim.env.VIRTUAL_ENV .. "/bin/pytest") then
  cmd = vim.env.VIRTUAL_ENV .. "/bin/pytest"
end

local pytest = Runner:init({
  command = cmd,
}, {
  python = [[
      ; Class
      ((class_definition
        name: (identifier) @class-name) @scope-root)

      ; Function
      ((function_definition
        name: (identifier) @function-name) @scope-root)
    ]],
})

function pytest:is_test(name)
  return string.match(name, "[Tt]est") and true
end

function pytest:build_test_args(args, tests)
  args[#args] = args[#args] .. "::" .. table.concat(tests, "::")
end

return pytest
