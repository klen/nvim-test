-- TODO
--
local Runner = require "nvim-test.runner"

local cargotest = Runner:init({ command = "cargo", args = { "test" }, package = false }, {
  rust = [[
      (
        (
          mod_item name: (identifier) @test-name
          (#match? @test-name "[Tt]est")
        )
      @scope-root)

      (
        (
          function_item name: (identifier) @test-name
          (#match? @test-name "[Tt]est")
        )
      @scope-root)
    ]],
})

function cargotest:build_args(args, filename, opts)
  -- for whole suite do nothing
  if not filename then
    return
  end

  -- Find a package
  if self.config.package then
    local crate = vim.fn.findfile("Cargo.toml", vim.fn.fnamemodify(filename, ":p") .. ";")
    if crate and #crate > 0 then
      table.insert(args, "-p")
      table.insert(args, vim.fn.fnamemodify(crate, ":p:h:t"))
    end
  end

  if opts.tests and #opts.tests > 0 then
    table.insert(args, table.concat(opts.tests, "::"))
    table.insert(args, "--")
    table.insert(args, "--exact")
  else
    local parts = vim.fn.split(vim.fn.fnamemodify(filename, ":.:r"), "/")
    if parts[#parts] == "main" or parts[#parts] == "lib" or parts[#parts] == "mod" then
      parts[#parts] = nil
    end
    if parts[1] == "src" then
      table.remove(parts, 1)
    end

    local modname = (#parts > 0) and table.concat(parts, "::")
    if modname then
      table.insert(args, modname .. "::")
    end
  end
end

return cargotest
