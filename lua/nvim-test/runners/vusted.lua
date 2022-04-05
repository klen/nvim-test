local Runner = require "nvim-test.runner"
local busted = require "nvim-test.runners.busted"

local vusted = Runner:init({
  command = "vusted",
  file_pattern = busted.config.file_pattern,
  find_files = busted.config.find_files,
}, {
  lua = busted.queries.lua,
})

function vusted:parse_testname(name)
  return busted:parse_testname(name)
end

function vusted:build_test_args(args, tests)
  return busted:build_test_args(args, tests)
end

return vusted
