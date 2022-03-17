-- TODO
--
local Runner = require "nvim-test.runner"

local gotest = Runner:init({ command = "go test" }, {
  go = [[
      ((function_declaration
        name: (identifier) @function-name) @scope-root)
    ]],
})

function gotest:is_test(name)
  return string.match(name, "^Test") or string.match(name, "^Example")
end

function gotest:build_args(filename, opts)
  local args = self.config.args
  if not filename then
    return args .. " ./..."
  end

  local path = "./" .. vim.fn.fnamemodify(filename, ":.:h")
  args = args .. ((path == "./.") and "" or (path .. "/..."))
  if opts.tests then
    args = string.format(" -run %s ", vim.fn.shellescape(opts.tests[1] .. "$")) .. args
  end
  return args
end

return gotest
