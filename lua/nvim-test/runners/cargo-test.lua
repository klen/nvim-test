local ts = vim.treesitter
local ts_parsers = require("nvim-treesitter.parsers")
local ts_utils = require "nvim-treesitter.ts_utils"

local Runner = require "nvim-test.runner"

local cargotest = Runner:init({ command = "cargo", args = { "test" }, package = false }, {
  rust = [[
  (
    mod_item name: (identifier) @mod-name
    (#match? @mod-name "[Tt]est")
  )

  (
    (
      (attribute_item (attribute (identifier) @attr-name))
      (function_item name: (identifier) @test-name) @fun
    ) @scope-root
  )
  ]]
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

function cargotest:find_nearest_test(filetype)
  local query = ts.get_query(ts_parsers.ft_to_lang(filetype), "nvim-test")

  local found_func = false
  local found_test = false
  local found_mod = false
  local result = {}
  local curnode = ts_utils.get_node_at_cursor()
  if not curnode then
    return result
  end

  local curLine, _, _, _ = curnode:range()

  while curnode do
    for capture_id, capture_node, _ in query:iter_captures(curnode, 0) do
      local start_node, _, end_node, _ = capture_node:range()
      if query.captures[capture_id] == "fun" and start_node <= curLine and
          end_node >= curLine then
        found_func = true
      end

      if query.captures[capture_id] == "test-name" and found_func and not found_test then
        local name = self:parse_testname(ts.query.get_node_text(capture_node, 0))
        table.insert(result, name)
        found_test = true
      end

      if query.captures[capture_id] == "mod-name" and not found_mod then
        local name = self:parse_testname(ts.query.get_node_text(capture_node, 0))
        table.insert(result, 1, name)
        found_mod = true
      end
    end

    curnode = curnode:parent()
  end

  return result
end

return cargotest

