local Runner = require("nvim-test.runner")

local query = [[
      (
        (call_expression
          function: (identifier) @method-name
          (#match? @method-name "^(Describe|Context|It)$")
          arguments: (argument_list ((interpreted_string_literal) @test-name))
        )
      @scope-root)
    ]]

local gotest = Runner:init({
	command = "ginkgo",
	args = { "run", "-v" },
	file_pattern = "\\v([^.]+_test)\\.go$", -- determine whether a file is a testfile
	find_files = { "{name}_test.go" }, -- find testfile for a file
}, {
	go = query,
})

function gotest:build_args(args, filename, opts)
	if filename then
		table.insert(args, "--focus-file")
		table.insert(args, filename)

		if opts.tests and next(opts.tests) ~= nil then
			local nodes = {}

			for _, v in ipairs(opts.tests) do
				nodes[#nodes + 1] = v:gsub('"', "")
			end

			local regexp = string.format("\\b%s\\b", table.concat(nodes, " "))

			table.insert(args, "--focus")
			table.insert(args, regexp)
		end

		local path = vim.fn.fnamemodify(filename, ":.:h")

		if path ~= "." then
			table.insert(args, string.format("./%s", path))
		end
	else
		table.insert(args, "./...")
	end
end

return gotest
