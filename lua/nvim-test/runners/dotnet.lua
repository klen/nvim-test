local Runner = require "nvim-test.runner"

local cstest = Runner:init({
  command = "dotnet",
  args = { "test" },
  file_pattern = "\\v(test/.*|Tests)\\.cs$",
  find_files = { "{name}Tests.{ext}", "Tests.{ext}" }, -- find testfile for a file
}, {
  c_sharp = [[
    ; Namespace
    ((namespace_declaration name: (identifier) @test-name) @scope-root)

    ; Class
    ((class_declaration name: (identifier) @test-name) @scope-root)

    ; Method
    ((method_declaration
        (attribute_list
            (attribute name: (identifier) @attribute-name
            (#match? @attribute-name "(Fact|Theory|Test|TestMethod)")
            ; attributes used by xunit, nunit and mstest
        ))
        name: (identifier) @test-name)
    @scope-root)

    ]],
})

function cstest:get_tf_parser_name()
  return "c_sharp"
end

function cstest:build_test_args(args, tests)
  table.insert(args, "--filter")
  table.insert(args, "FullyQualifiedName=" .. table.concat(tests, "."))
end

return cstest
