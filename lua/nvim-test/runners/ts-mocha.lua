local Runner = require "nvim-test.runner"
local mocha = require "nvim-test.runners.mocha"

local tsmocha = Runner:init({
  command = { "./node_modules/.bin/ts-mocha", "ts-mocha" },
  file_pattern = "\\v(tests?/.*|test)\\.(ts|tsx)$",
  find_files = { "{name}.test.{ext}" },
}, {
  typescript = mocha.queries.typescript,
})

function tsmocha:parse_testname(name)
  return mocha:parse_testname(name)
end

function tsmocha:build_test_args(args, tests)
  return mocha:build_test_args(args, tests)
end

return tsmocha
