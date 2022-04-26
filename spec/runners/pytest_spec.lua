local helpers = require "spec.helpers"

describe("pytest", function()
  before_each(helpers.before_each)
  after_each(helpers.after_each)

  local filename = "spec/fixtures/test.py"

  it("runner", function()
    local runner = require "nvim-test.runners.pytest"
    assert.is.truthy(runner)
    assert.is.equal("pytest", runner.config.command)

    assert.is_false(runner:is_testfile "somefile.py")
    assert.is_true(runner:is_testfile "somefile_test.py")
    assert.is_true(runner:is_testfile "test_somefile.py")
    assert.is_true(runner:is_testfile "tests.py")
  end)

  it("run suite", function()
    helpers.view(filename)
    vim.api.nvim_command "TestSuite"
    assert.are.same(vim.g.test_latest.cmd, { "pytest" })
  end)

  it("run file", function()
    helpers.view(filename)
    vim.api.nvim_command "TestFile"
    assert.are.same(vim.g.test_latest.cmd, { "pytest", filename })
  end)

  it("run nearest function", function()
    helpers.view(filename, 4)
    vim.api.nvim_command "TestNearest"
    assert.are.same(vim.g.test_latest.cmd, { "pytest", filename .. "::test_base" })
  end)

  it("run nearest method", function()
    helpers.view(filename, 13)
    vim.api.nvim_command "TestNearest"
    assert.are.same(vim.g.test_latest.cmd, { "pytest", filename .. "::MyTest::test_method2" })
  end)

  it("run latest", function()
    helpers.view(filename)
    vim.api.nvim_command "TestFile"
    assert.are.same(vim.g.test_latest.cmd, { "pytest", filename })

    vim.api.nvim_command "TestLast"
    assert.are.same(vim.g.test_latest.cmd, { "pytest", filename })
  end)

  it("setup args", function()
    require("nvim-test.runners.pytest"):setup { args = { "-v" } }
    helpers.view(filename)
    vim.api.nvim_command "TestFile"
    assert.are.same(vim.g.test_latest.cmd, { "pytest", "-v", filename })
  end)
end)
