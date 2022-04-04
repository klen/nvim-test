local Runner = require "nvim-test.runner"
local pytest = require "nvim-test.runners.pytest"

local pyunit = Runner:init({
  command = vim.env.VIRTUAL_ENV and vim.env.VIRTUAL_ENV .. "/bin/python" or "python",
  args = { "-m", "unittest" },
}, {
  python = pytest.queries.python,
})

function pyunit:is_test(name)
  return pytest:is_test(name)
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
