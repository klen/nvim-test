-- TODO
--
local Runner = require "nvim-test.runner"

local cargotest = Runner:init({ command = "cargo test" }, {
  rust = [[
      (
        (mod_item
          name: (identifier) @module-name)
      @scope-root)
      (
        (function_item
          name: (identifier) @function-name)
      @scope-root)
    ]],
})

function cargotest:is_test(name)
  return string.match(name, "[Tt]est") and true
end

function cargotest:build_args(filename, opts)
  -- for whole suite do nothing
  local args = self.config.args
  if not filename then
    return args
  end

  local parts = vim.fn.split(vim.fn.fnamemodify(filename, ":.:r"), "/")
  if parts[#parts] == "main" or parts[#parts] == "lib" or parts[#parts] == "mod" then
    parts[#parts] = nil
  end
  if parts[1] == "src" then
    table.remove(parts, 1)
  end

  local modname = (#parts > 0) and table.concat(parts, "::")
  if modname then
    modname = " " .. vim.fn.shellescape(modname .. "::")
  end

  if opts.tests and #opts.tests > 0 then
    return args .. " " .. table.concat(opts.tests, "::") .. " -- --exact"
  end

  return args .. (modname or "")
end

return cargotest
