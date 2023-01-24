local helpers = require "spec.helpers"
local pwd

-- to list all available tests run "python -m unittest discover -v"
describe("pyunit", function()
  before_each(function()
    helpers.before_each { run = false, runners = { python = "nvim-test.runners.pyunit" } }
    pwd = vim.fn.getcwd()
    vim.api.nvim_command "cd spec/fixtures/python"
  end)

  after_each(function()
    helpers.after_each()
    vim.api.nvim_command("cd " .. pwd)
  end)

  local filename = "test.py"

  it("runner", function()
    local runner = require "nvim-test.runners.pyunit"
    assert.is.truthy(runner)

    assert.is_false(runner:is_testfile "somefile.py")
    assert.is_true(runner:is_testfile "test_somefile.py")
  end)

  it("run suite", function()
    helpers.view(filename)
    vim.api.nvim_command "TestSuite"
    assert.are.same(
      { "python", "-m", "unittest" },
      vim.g.test_latest.cmd
    )
  end)

  it("run file", function()
    helpers.view(filename)
    vim.api.nvim_command "TestFile"
    assert.are.same(
      { "python", "-m", "unittest", "test" },
      vim.g.test_latest.cmd
    )
  end)

  it("run nearest function", function()
    helpers.view(filename, 10)
    vim.api.nvim_command "TestNearest"
    assert.are.same(
      { "python", "-m", "unittest", "test.MyTest.test_method1" },
      vim.g.test_latest.cmd
    )
  end)

  it("run nearest method", function()
    helpers.view(filename, 13)
    vim.api.nvim_command "TestNearest"
    assert.are.same(
      { "python", "-m", "unittest", "test.MyTest.test_method2" },
      vim.g.test_latest.cmd
    )
  end)

  it("run latest", function()
    helpers.view(filename)
    vim.api.nvim_command "TestFile"
    assert.are.same(
      { "python", "-m", "unittest", "test" },
      vim.g.test_latest.cmd
    )

    vim.api.nvim_command "TestLast"
    assert.are.same(
      { "python", "-m", "unittest", "test" },
      vim.g.test_latest.cmd
    )
  end)
end)
