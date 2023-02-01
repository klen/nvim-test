local Runner = require "nvim-test.runner"
local utils = require "nvim-test.utils"

local rspec = Runner:init({
  command = { "rspec", "bundle" },
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

function rspec:find_working_directory(filename)
  local root = self.config.working_directory
  if not root then
    root = utils.find_relative_root(filename, "Gemfile")
  end
  return root
end

function rspec:build_args(args, filename, opts)
  if self.config.command == "bundle" then
    table.insert(args, "exec")
    table.insert(args, "rspec")
  end

  if filename then
    table.insert(args, filename)
  end
  if opts.tests and #opts.tests > 0 then
    self:build_test_args(args, opts.tests)
  end
end

function rspec:build_test_args(args, tests)
  table.insert(args, "--example")
  table.insert(args, table.concat(tests, " "))
end

return rspec
