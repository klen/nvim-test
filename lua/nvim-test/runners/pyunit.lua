local Runner = require "nvim-test.runner"

local pyunit = Runner:init({
  command = vim.env.VIRTUAL_ENV and vim.env.VIRTUAL_ENV .. "/bin/python" or "python",
  args = { "-m", "unittest" },
}, {
  python = [[
      ; Class
      ((class_definition
        name: (identifier) @class-name) @scope-root)

      ; Function
      ((function_definition
        name: (identifier) @function-name) @scope-root)
    ]],
})

function pyunit:is_test(name)
  return string.match(name, "[Tt]est") and true
end

function pyunit:build_args(args, filename, opts)
  if filename then
    local path, _ = vim.fn.fnamemodify(filename, ":.:r"):gsub("/", ".")
    table.insert(args, path)
  end
  if opts.tests and #opts.tests > 0 then
    args[#args] = args[#args] .. "." .. table.concat(opts.tests, ".")
  end
end

return pyunit
