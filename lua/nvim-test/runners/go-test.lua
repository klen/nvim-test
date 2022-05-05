-- TODO
--
local Runner = require "nvim-test.runner"

local gotest = Runner:init({
  command = "go",
  args = { "test", "-v" },
  file_pattern = "\\v([^.]+_test)\\.go$",   -- determine whether a file is a testfile
  find_files = { "{name}_test.go" },                  -- find testfile for a file
}, {
  go = [[
      (function_declaration
        name: (identifier) @scope-root)
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
    if opts.tests and next(opts.tests) ~= nil then
        -- table.insert(args, "-run")
        local args_tests = ""
        for test_name, _ in pairs(opts.tests) do
            args_tests = args_tests .. test_name .. "|"
        end
        args_tests = args_tests:sub(1, -2)
        args_tests = '-run=(' .. args_tests .. ')$'
        table.insert(args, args_tests)
    end
  else
    table.insert(args, "./...")
  end
end

return gotest
