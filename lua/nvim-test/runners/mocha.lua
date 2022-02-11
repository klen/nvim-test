local Runner = require "nvim-test.runner"
local jest = require "nvim-test.runners.jest"
local local_cmd = "./node_modules/.bin/mocha"

local mocha = Runner:init {
  command = vim.fn.filereadable(local_cmd) ~= 0 and local_cmd or "mocha",
  queries = {
    javascript = jest.config.queries.javascript,
    typescript = jest.config.queries.typescript,
  },
}

function mocha:parse_name(name)
  return name:gsub("^[\"'`]", ""):gsub("[\"'`]$", "")
end

function mocha:build_test_args(tests)
  return string.format(" -f '%s'", table.concat(tests, " "))
end

return mocha
