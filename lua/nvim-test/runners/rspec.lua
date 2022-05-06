local Runner = require "nvim-test.runner"

local rspec = Runner:init({
  command = { "rspec" },
  file_pattern = "\\v(spec_[^.]+|[^.]+_spec)\\.rb$",
  find_files = { "{name}_spec.rb" },
}, {
  ruby = [[
      (
        (call
          method: (identifier) @method-name
          (#match? @method-name "(describe|it|context)")
          arguments: (argument_list (string (string_content) @test-name))
        )
      @scope-root)
    ]],
})

function rspec:build_test_args(args, tests)
  table.insert(args, "--example")
  table.insert(args, table.concat(tests, " "))
end

return rspec
