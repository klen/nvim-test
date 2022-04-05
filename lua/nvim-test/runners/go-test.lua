-- TODO
--
local Runner = require "nvim-test.runner"

local gotest = Runner:init({
  command = "go",
  args = { "test", "-v" },
}, {
  go = [[
      ((function_declaration
        name: (identifier) @function-name) @scope-root)
    ]],
})

function gotest:is_test(name)
  return string.match(name, "^Test") or string.match(name, "^Example")
end

function gotest:build_args(args, filename, opts)
  if filename then
    local path = vim.fn.fnamemodify(filename, ":.:h")
    if path ~= "." then
      table.insert(args, string.format("./%s/...", path))
    end
    if opts.tests and #opts.tests > 0 then
      table.insert(args, "-run")
      table.insert(args, opts.tests[1] .. "$")
    end
  else
    table.insert(args, "./...")
  end
end

return gotest
