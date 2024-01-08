local helpers = require "spec.helpers"
local pwd

describe("pytest", function()
  before_each(function()
    helpers.before_each { run = false, runners = { python = "nvim-test.runners.pytest" } }
    pwd = vim.fn.getcwd()
    vim.api.nvim_command "cd spec/fixtures/python"
  end)

  after_each(function()
    helpers.after_each()
    vim.api.nvim_command("cd " .. pwd)
  end)

  local filename = "test.py"

  it("runner", function()
    local runner = require "nvim-test.runners.pytest"
    assert.is.truthy(runner)
    assert.is.equal("pytest", runner.config.command)

    assert.is_false(runner:is_testfile "somefile.py")
    assert.is_true(runner:is_testfile "somefile_test.py")
    assert.is_true(runner:is_testfile "test_somefile.py")
    assert.is_true(runner:is_testfile "tests.py")
  end)

  -- TODO: does not work if you run this command, find's no tests
  it("run suite", function()
    helpers.view(filename)
    vim.api.nvim_command "TestSuite"
    assert.are.same({ "pytest" }, vim.g.test_latest.cmd)
  end)

  it("run file", function()
    helpers.view(filename)
    vim.api.nvim_command "TestFile"
    assert.are.same({ "pytest", filename }, vim.g.test_latest.cmd)
  end)

  it("run nearest function", function()
    helpers.view(filename, 4)
    vim.api.nvim_command "TestNearest"
    assert.are.same({ "pytest", filename .. "::test_base" }, vim.g.test_latest.cmd)
  end)

  it("run nearest method", function()
    helpers.view(filename, 13)
    vim.api.nvim_command "TestNearest"
    assert.are.same({ "pytest", filename .. "::MyTest::test_method2" }, vim.g.test_latest.cmd)
  end)

  it("run latest", function()
    helpers.view(filename)
    vim.api.nvim_command "TestFile"
    assert.are.same({ "pytest", filename }, vim.g.test_latest.cmd)

    vim.api.nvim_command "TestLast"
    assert.are.same({ "pytest", filename }, vim.g.test_latest.cmd)
  end)

  it("setup args", function()
    require("nvim-test.runners.pytest"):setup { args = { "-v" } }
    helpers.view(filename)
    vim.api.nvim_command "TestFile"
    assert.are.same({ "pytest", "-v", filename }, vim.g.test_latest.cmd)
  end)
end)
