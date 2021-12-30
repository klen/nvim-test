local Runner = require "nvim-test.runner"

local pyunit = Runner:init {
  command = "python -m unittest",
  queries = {
    python = [[
      ; Class
      ((class_definition
        name: (identifier) @class-name) @scope-root)

      ; Function
      ((function_definition
        name: (identifier) @function-name) @scope-root)
    ]],
  },
}

function pyunit:is_test(name)
  return string.match(name, "[Tt]est") and true
end

function pyunit:build_args(filename, opts)
  local args = ""
  if filename then
    args = args .. " " .. vim.fn.fnamemodify(filename, ":.:r"):gsub("/", ".")
  end
  if opts.tests and #opts.tests > 0 then
    args = args .. "." .. table.concat(opts.tests, ".")
  end
  if self.config.args then
    args = args .. " " .. self.config.args
  end
  return args
end

return pyunit
