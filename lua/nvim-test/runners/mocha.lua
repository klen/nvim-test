local Runner = require "nvim-test.runner"
local jest = require "nvim-test.runners.jest"
local localCmd = "./node_modules/.bin/mocha"

local mocha = Runner:init({
  command = vim.fn.filereadable(localCmd) ~= 0 and localCmd or "mocha",
}, {
  javascript = jest.queries.javascript,
  typescript = jest.queries.typescript,
})

function mocha:parse_name(name)
  return jest:parse_name(name)
end

function mocha:build_test_args(args, tests)
  table.insert(args, "-f")
  table.insert(args, table.concat(tests, " "))
end

return mocha
