local Runner = require "nvim-test.runner"
local jest = require "nvim-test.runners.jest"
local local_cmd = "./node_modules/.bin/ts-mocha"

local tsmocha = Runner:init {
  command = vim.fn.filereadable(local_cmd) ~= 0 and local_cmd or "ts-mocha",
  queries = {
    typescript = jest.config.queries.javascript,
  },
}

function tsmocha:parse_name(name)
  return name:gsub("^[\"'`]", ""):gsub("[\"'`]$", "")
end

function tsmocha:build_test_args(tests)
  return string.format(" -f '%s'", table.concat(tests, " "))
end

return tsmocha
