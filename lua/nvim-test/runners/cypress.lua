local Runner = require "nvim-test.runner"
local local_cmd = "./node_modules/.bin/cypress"

local cypress = Runner:init {
  command = vim.fn.filereadable(local_cmd) ~= 0 and local_cmd or "cypress",
}

function cypress:build_args(filename)
  local args = self.config.args .. " run"
  if filename then
    args = args .. " --spec " .. filename
  end
  return args
end

return cypress
