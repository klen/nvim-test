local helpers = require "spec.helpers"

describe("gotest", function()
  local pwd

  before_each(function()
    helpers.before_each()
    pwd = vim.fn.getcwd()
    vim.api.nvim_command "cd spec/fixtures/go"
  end)
  after_each(function()
    helpers.after_each()
    vim.api.nvim_command("cd " .. pwd)
  end)

  local filename = "mypackage_test.go"

  it("run suite", function()
    helpers.view(filename)
    vim.api.nvim_command "TestSuite"
    assert.are.same({ "go", "test", "-v", "./..." }, vim.g.test_latest.cmd)
  end)

  it("run file", function()
    helpers.view(filename)
    vim.api.nvim_command "TestFile"
    assert.are.same({ "go", "test", "-v" }, vim.g.test_latest.cmd)
  end)

  it("run nested file", function()
    helpers.view(filename)
    vim.api.nvim_command "cd ../"
    vim.api.nvim_command "TestFile"
    assert.are.same({ "go", "test", "-v", "./go/..." }, vim.g.test_latest.cmd)
  end)

  it("run nearest function", function()
    helpers.view(filename, 6)
    vim.api.nvim_command "TestNearest"
    assert.are.same({ "go", "test", "-v", "-run", "TestNumbers$" }, vim.g.test_latest.cmd)
  end)

  it("run latest", function()
    helpers.view(filename)
    vim.api.nvim_command "TestFile"
    assert.are.same({ "go", "test", "-v" }, vim.g.test_latest.cmd)

    vim.api.nvim_command "TestLast"
    assert.are.same({ "go", "test", "-v" }, vim.g.test_latest.cmd)
  end)
end)
