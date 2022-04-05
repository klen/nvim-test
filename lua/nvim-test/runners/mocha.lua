local Runner = require "nvim-test.runner"
local jest = require "nvim-test.runners.jest"

local mocha = Runner:init({
  command = { "./node_modules/.bin/mocha", "mocha" },
  file_pattern = "\\v(tests?/.*|test)\\.(js|jsx|coffee)$",
  find_files = { "{name}.test.{ext}" },
}, {
  javascript = jest.queries.javascript,
  typescript = jest.queries.typescript,
})

function mocha:parse_testname(name)
  return jest:parse_testname(name)
end

function mocha:build_test_args(args, tests)
  table.insert(args, "-f")
  table.insert(args, table.concat(tests, " "))
end

return mocha
