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
  return name:gsub("^[\"'`]", ""):gsub("[\"'`]$", "")
end

function mocha:build_test_args(tests)
  return string.format(" -f '%s'", table.concat(tests, " "))
end

return mocha
