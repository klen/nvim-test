local Runner = require "nvim-test.runner"
local localCmd = "./node_modules/.bin/cypress"

local cypress = Runner:init {
  command = vim.fn.filereadable(localCmd) ~= 0 and localCmd or "cypress",
}

function cypress:build_args(filename)
  local args = self.config.args .. " run"
  if filename then
    args = args .. " --spec " .. filename
  end
  return args
end

return cypress
