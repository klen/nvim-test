local Runner = require "nvim-test.runner"
local busted = require "nvim-test.runners.busted"

local vusted = Runner:init({ command = "vusted" }, {
  lua = busted.queries.lua,
})

function vusted:parse_name(name)
  return busted:parse_name(name)
end

function vusted:build_test_args(args, tests)
  return busted:build_test_args(args, tests)
end

return vusted
