local Runner = require "nvim-test.runner"
local utils = require "nvim-test.utils"

local query = [[
  ((expression_statement
    (call_expression
      function: (identifier) @method-name
      (#match? @method-name "^(describe|test|it)")
      arguments: (arguments [
        ((string) @test-name)
        ((template_string) @test-name)
      ]
    )))
  @scope-root)
]]

local jest = Runner:init({
  command = { "./node_modules/.bin/jest", "jest" },
  file_pattern = "\\v(__tests__/.*|(spec|test))\\.(js|jsx|coffee|ts|tsx)$",
  find_files = { "{name}.test.{ext}", "{name}.spec.{ext}" },
}, {
  javascript = query,
  typescript = query,
})

function jest:parse_testname(name)
  return name:gsub("^[\"'`]", ""):gsub("[\"'`]$", "")
end

function jest:build_test_args(args, tests)
  table.insert(args, "-t")
  table.insert(args, "^" .. table.concat(tests, " ") .. "$")
end

function jest:find_working_directory(filename)
  local root = self.config.working_directory
  if not root then
    root = utils.find_relative_root(filename, "package.json")
  end
  return root
end

return jest
