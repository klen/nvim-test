local Runner = require("nvim-test.runner")

local zig_test = Runner:init({ command = "zig" }, {
  zig = [[
    (TestDecl . [(STRINGLITERALSINGLE) @test-name (IDENTIFIER) @test-name]) @scope-root
  ]],
})

function zig_test:parse_testname(name)
  return name:gsub('^@?"', ""):gsub('"$', "")
end

function zig_test:build_args(args, filename, opts)
  if not filename then
    table.insert(args, "build")
    table.insert(args, "test")
    return
  end

  table.insert(args, "test")
  table.insert(args, filename)

  if opts.tests and #opts.tests > 0 then
    for _, test in ipairs(opts.tests) do
      table.insert(args, "--test-filter")
      table.insert(args, test)
    end
  end
end

return zig_test
