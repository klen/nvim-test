-- TODO
--
local Runner = require "nvim-test.runner"

local gotest = Runner:init({
  command = "go",
  args = { "test", "-v" },
  file_pattern = "\\v([^.]+_test)\\.go$", -- determine whether a file is a testfile
  find_files = { "{name}_test.go" }, -- find testfile for a file
}, {
  go = [[
      (
        (
          function_declaration name: (identifier) @test-name
          (#match? @test-name "^(Test|Benchmark|Fuzz)")
        )
      @scope-root)
    ]],
})

function gotest:build_args(args, filename, opts)
  if filename then
    local path = vim.fn.fnamemodify(filename, ":.:h")
    if path ~= "." then
      table.insert(args, string.format("./%s/...", path))
    end
    if opts.tests and next(opts.tests) ~= nil then
      table.insert(args, "-run")
      table.insert(args, opts.tests[1] .. "$")
    end
  else
    table.insert(args, "./...")
  end
end

return gotest
