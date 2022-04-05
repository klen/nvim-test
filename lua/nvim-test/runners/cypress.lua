local Runner = require "nvim-test.runner"
local jest = require "nvim-test.runners.jest"

local cypress = Runner:init({
  command = { "./node_modules/.bin/cypress", "cypress" },
  args = { "run" },
  file_pattern = jest.config.file_pattern,
  find_files = jest.config.find_files,
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
