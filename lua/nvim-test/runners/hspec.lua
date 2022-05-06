local Runner = require "nvim-test.runner"

local hspec = Runner:init({
  command = { "runhaskell" },
  file_pattern = "\\v(Spec)\\.hs$",
  find_files = { "{name}Spec.hs", "Spec.hs" },
}, {
  haskell = [[
      ((stmt (exp_infix (exp_apply 
          (exp_name) @exp-name
          (#match? @exp-name "^(describe|it)")
          (exp_literal)  @test-name
        )
      ))
      @scope-root)
    ]],
})

function hspec:parse_testname(name)
  return name:gsub("^[\"'`]", ""):gsub("[\"'`]$", "")
end

function hspec:build_test_args(args, tests)
  table.insert(args, "--match")
  table.insert(args, table.concat(tests, "/"))
end

return hspec
