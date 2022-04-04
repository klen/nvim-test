local Runner = require "nvim-test.runner"
local jest = require "nvim-test.runners.jest"
local localCmd = "./node_modules/.bin/ts-mocha"

local tsmocha = Runner:init({
  command = vim.fn.filereadable(localCmd) ~= 0 and localCmd or "ts-mocha",
}, {
  typescript = jest.queries.javascript,
})

function tsmocha:parse_name(name)
  return name:gsub("^[\"'`]", ""):gsub("[\"'`]$", "")
end

function tsmocha:build_test_args(args, tests)
  table.insert(args, "-f")
  table.insert(args, table.concat(tests, " "))
end

return tsmocha
