local Runner = require "nvim-test.runner"

local busted = Runner:init {
  command = "busted",
  queries = {
    lua = [[
      ((function_call (identifier) (arguments (string) @method-name (function_definition))) @scope-root)
		]],
  },
}

function busted:parse_name(name)
  return name:gsub("^[\"']", ""):gsub("[\"']$", "")
end

function busted:build_test_args(tests)
  return string.format(" --filter '%s'", table.concat(tests, " "))
end

return busted
