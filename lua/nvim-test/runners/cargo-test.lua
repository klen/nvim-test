local Runner = require "nvim-test.runner"
local ts_parsers = require("nvim-treesitter.parsers")
local ts_utils = require("nvim-treesitter.ts_utils")
local utils = require "nvim-test.utils"
local ts = vim.treesitter

local query = [[
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
    ]]

local cargotest = Runner:init({ command = "cargo", args = { "test" }, package = false }, {
  rust = query,
})

function cargotest:find_nearest_test(filetype)
  local ts_query = ts.get_query(ts_parsers.ft_to_lang(filetype), "nvim-test")
  local result = {}
  if ts_query then
    local curnode = ts_utils.get_node_at_cursor()
    while curnode do
        for pattern, match, _ in ts_query:iter_matches(curnode, 0) do
            for id, node in pairs(match) do
                local name = ts_query.captures[id]
                if name == "test-name" then
                    local test_name = cargotest:parse_testname(ts.query.get_node_text(node, 0))
                    local parse_testname_func = function (t_name)
                        return self:parse_testname(t_name)
                    end
                    local fqdn = utils:get_fully_qualified_name(filetype, node, test_name, parse_testname_func, "::")
                    table.insert(result, fqdn)
                    return result
                end
            end
        end
        curnode = curnode:parent()
    end
  end
  return result
end

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
