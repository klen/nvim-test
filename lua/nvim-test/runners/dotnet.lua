local Runner = require "nvim-test.runner"
local utils = require "nvim-test.utils"
local ts_parsers = require("nvim-treesitter.parsers")
local ts_utils = require("nvim-treesitter.ts_utils")
local ts = vim.treesitter

local cstest = Runner:init({
  command = "dotnet",
  args = { "test" },
  file_pattern = "\\v(test/.*|Tests)\\.cs$",
  find_files = { "{name}Tests.{ext}", "Tests.{ext}" }, -- find testfile for a file
}, {
  c_sharp = [[
    ; Method
    (
        (method_declaration
            (attribute_list
                (attribute name: (identifier) @attribute-name
                (#match? @attribute-name "(Fact|Theory|Test|TestMethod)")
                ; attributes used by xunit, nunit and mstest
            ))
            name: (identifier) @test-name)
        @scope-root
    )

    ]],
})

function cstest:find_tests_in_file(filetype)
  local parser_name = ts_parsers.ft_to_lang(filetype)
  local query = ts.get_query(parser_name, "nvim-test")
  local result = {}
  if query then
    local parser = ts.get_parser(0, parser_name)
    local root = unpack(parser:parse()):root()
    for pattern, match, metadata in query:iter_matches(root, 0) do
      for id, node in pairs(match) do
        local name = query.captures[id]
        if name == "test-name" then
          local test_name = self:parse_testname(ts.query.get_node_text(node, 0))
          local fqn = self:get_fully_qualified_name(filetype, node, test_name)
          table.insert(result, fqn)
        end
      end
    end
  end
  return result
end

function cstest:find_nearest_test(filetype)
  local query = ts.get_query(ts_parsers.ft_to_lang(filetype), "nvim-test")
  local result = {}
  if query then
    local curnode = ts_utils.get_node_at_cursor()
    while curnode do
        for pattern, match, metadata in query:iter_matches(curnode, 0) do
            for id, node in pairs(match) do
                local name = query.captures[id]
                if name == "test-name" then
                    local test_name = self:parse_testname(ts.query.get_node_text(node, 0))
                    local fqn = self:get_fully_qualified_name(filetype, node, test_name)
                    table.insert(result, fqn)
                    return result
                end
            end
        end
        curnode = curnode:parent()
    end
  end
  return result
end

function cstest:get_fully_qualified_name(filetype, curnode, name)
    while curnode do
        local type = curnode:type()
        if type == "class_declaration" or
           type == "namespace_declaration" or
           type == "file_scoped_namespace_declaration"
        then
            for node, field_name in curnode:iter_children() do
                if node:named() then
                    if field_name == "name" then
                        name =  ts.query.get_node_text(node, 0) .. "." .. name
                    end
                end
            end
        end
        curnode = curnode:parent()
    end
    return name
end

function cstest:find_working_directory(filename)
  local root = self.config.working_directory
  if not root then
    root = utils.find_relative_root(filename, "^.+%.csproj$")
  end
  return root
end

function cstest:build_args(args, filename, opts)
  if opts.tests and #opts.tests > 0 then
    table.insert(args, "--filter")
    table.insert(args, "FullyQualifiedName=" .. table.concat(opts.tests, "|"))
  end
end

return cstest
