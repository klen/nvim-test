local Runner = require "nvim-test.runner"
local hspec = require "nvim-test.runners.hspec"

local stack = Runner:init({
  command = { "stack" },
  args = { "test" },
  file_pattern = hspec.config.file_pattern,
  find_files = hspec.config.find_files,
}, {
  haskell = hspec.queries.haskell,
})

function stack:parse_testname(name)
  return hspec:parse_testname(name)
end

function stack:build_test_args(args, tests)
  table.insert(
    args,
    "--test-arguments=" .. string.format("'--match \"%s\"'", table.concat(tests, "/"))
  )
end

return stack
