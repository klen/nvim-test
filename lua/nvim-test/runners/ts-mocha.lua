local Runner = require "nvim-test.runner"
local mocha = require "nvim-test.runners.mocha"
local localCmd = "./node_modules/.bin/ts-mocha"

local tsmocha = Runner:init({
  command = vim.fn.filereadable(localCmd) ~= 0 and localCmd or "ts-mocha",
}, {
  typescript = mocha.queries.typescript,
})

function tsmocha:parse_name(name)
  return mocha:parse_name(name)
end

function tsmocha:build_test_args(args, tests)
  return mocha:build_test_args(args, tests)
end

return tsmocha
