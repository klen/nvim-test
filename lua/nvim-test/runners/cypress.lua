local Runner = require "nvim-test.runner"
local localCmd = "./node_modules/.bin/cypress"
local jest = require "nvim-test.runners.jest"

local cypress = Runner:init({
  command = vim.fn.filereadable(localCmd) ~= 0 and localCmd or "cypress",
}, {
  javascript = jest.queries.javascript,
})

function cypress:build_args(filename)
  local args = self.config.args .. " run"
  if filename then
    args = args .. " --spec " .. filename
  end
  return args
end

return cypress
