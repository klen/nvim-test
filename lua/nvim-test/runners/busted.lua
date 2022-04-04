local Runner = require "nvim-test.runner"

local busted = Runner:init({ command = "busted" }, {
  lua = [[ ((function_call (identifier) (arguments (string) @method-name (function_definition))) @scope-root) ]],
})

function busted:parse_name(name)
  return name:gsub("^[\"']", ""):gsub("[\"']$", "")
end

function busted:build_test_args(args, tests)
  table.insert(args, "--filter")
  table.insert(args, table.concat(tests, " "))
  return args
end

return busted
