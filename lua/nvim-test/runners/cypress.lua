local Runner = require "nvim-test.runner"
local localCmd = "./node_modules/.bin/cypress"
local jest = require "nvim-test.runners.jest"

local cypress = Runner:init({
  command = vim.fn.filereadable(localCmd) ~= 0 and localCmd or "cypress",
  args = { "run" },
}, {
  javascript = jest.queries.javascript,
})

function cypress:build_args(args, filename, _)
  if filename then
    table.insert(args, "--spec")
    table.insert(args, filename)
  end
end

return cypress
