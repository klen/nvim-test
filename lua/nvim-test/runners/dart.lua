local Runner = require "nvim-test.runner"

local dart = Runner:init({
  command = "dart",
  args = { "test" },
  file_pattern = "\\v_test\\.dart$",
  find_files = { "{name}_test.dart", "test/{name}_test.dart" },
}, {
  dart = [[
    ; Match test('name', ...) and group('name', ...)
    ((function_expression
      body: (function_body
        (expression_statement
          (function_invocation
            function: (identifier) @method-name
            (#match? @method-name "^(test|group)$")
            arguments: (arguments
              (string (string_content) @test-name)
            )
          )
        )
      )
    ) @scope-root)
  ]],
})

function dart:parse_testname(name)
  return name:gsub("^[\"']", ""):gsub("[\"']$", "")
end

function dart:build_test_args(args, tests)
  table.insert(args, "--name")
  table.insert(args, table.concat(tests, " "))
end

return dart
