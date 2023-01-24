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
  working_directory = utils.find_proj_dir('^.+%.csproj$', vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":h"))
}, {
    -- ; Namespace
    -- ((namespace_declaration name: (identifier) @ns-name) @scope-root)
    --
    -- ; Class
    -- ((class_declaration name: (identifier) @class-name) @scope-root)
    --
    -- (
    --     (class_declaration
    --         name: (identifier) @class-name
    --         body: (declaration_list
    --             (method_declaration
    --                 (attribute_list
    --                     (attribute name: (identifier) @attribute-name
    --                     (#match? @attribute-name "(Fact|Theory|Test|TestMethod)")
    --                     ; attributes used by xunit, nunit and mstest
    --                 ))
    --                 name: (identifier) @test-name))
    --     )
    --     @scope-root
    -- )
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
  --print("parser: " .. parser_name)
  local query = ts.get_query(parser_name, "nvim-test")
  local result = {}
  if query then
    local parser = ts.get_parser(0, parser_name)
    local root = unpack(parser:parse()):root()
    for pattern, match, metadata in query:iter_matches(root, 0) do
      --print("pattern: " .. vim.inspect(pattern))
      --print("match: " .. vim.inspect(match))
      for id, node in pairs(match) do
        local name = query.captures[id]
        --print("capture: " .. name)
        if name == "test-name" then
          local test_name = self:parse_testname(ts.query.get_node_text(node, 0))
          --print("test name: " .. test_name)
          local fqdn = self:get_fully_qualified_name(filetype, node, test_name)
          table.insert(result, fqdn)
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
            --print("pattern: " .. vim.inspect(pattern))
            --print("match: " .. vim.inspect(match))
            for id, node in pairs(match) do
                local name = query.captures[id]
                --print("capture: " .. name)
                if name == "test-name" then
                    local test_name = self:parse_testname(ts.query.get_node_text(node, 0))
                    --print("test name: " .. test_name)
                    local fqdn = self:get_fully_qualified_name(filetype, node, test_name)
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

function cstest:get_fully_qualified_name(filetype, curnode, name)
    while curnode do
        local type = curnode:type()
        --print("ts type: " .. type)
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
    --print("fqn: " .. name)
    return name
end

function cstest:build_args(args, filename, opts)
  print(filename)
  print(vim.inspect(opts.tests))
  if opts.tests and #opts.tests > 0 then
    table.insert(args, "--filter")
    table.insert(args, "FullyQualifiedName=" .. table.concat(opts.tests, "|"))
  end
end

return cstest
