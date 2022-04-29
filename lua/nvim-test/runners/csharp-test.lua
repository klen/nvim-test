local Runner = require "nvim-test.runner"

local cstest = Runner:init({
  command = "dotnet",
  args = { "test", "-v" },
  file_pattern = "\\v(test?/.*|Tests)\\.(cs)$",
  find_files = { "{name}Tests.{ext}", "Tests.{ext}" },                  -- find testfile for a file
}, {
  c_sharp = [[
    (method_declaration
        (attribute_list
            (attribute name: (identifier) @attribute-name
            (#match? @attribute-name "(Fact|Theory|Test|TestMethod)")
            ; attributes used by xunit, nunit and mstest
            ))
        name: (identifier) @scope-root
    )
    ]],
})

function cstest:get_tf_parser_name(filetype)
  return "c_sharp"
end

function cstest:build_args(args, filename, opts)
  if opts.tests and next(opts.tests) ~= nil then
    table.insert(args, "--filter")
    local args_tests = ""
    for test_name, _ in pairs(opts.tests) do
        args_tests = args_tests .. test_name .. "|"
    end
    args_tests = args_tests:sub(1, -2)
    table.insert(args, args_tests)
  end
end

return cstest
