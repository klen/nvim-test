local helpers = require "spec.lua.helpers"

describe("gotest", function()
  local pwd

  before_each(function()
    helpers.before_each()
    pwd = vim.fn.getcwd()
    vim.api.nvim_command "cd spec/lua/test/fixtures/go"
  end)
  after_each(function()
    helpers.after_each()
    vim.api.nvim_command("cd " .. pwd)
  end)

  local filename = "mypackage_test.go"

  it("run suite", function()
    helpers.view(filename)
    vim.api.nvim_command "TestSuite"
    assert.are.same(vim.g.test_latest.cmd, { "go", "test", "-v", "./..." })
  end)

  it("run file", function()
    helpers.view(filename)
    vim.api.nvim_command "TestFile"
    assert.are.same(vim.g.test_latest.cmd, { "go", "test", "-v" })
  end)

  it("run nested file", function()
    helpers.view(filename)
    vim.api.nvim_command "cd ../"
    vim.api.nvim_command "TestFile"
    assert.are.same(vim.g.test_latest.cmd, { "go", "test", "-v", "./go/..." })
  end)

  it("run nearest function", function()
    helpers.view(filename, 6)
    vim.api.nvim_command "TestNearest"
    assert.are.same(vim.g.test_latest.cmd, { "go", "test", "-v", "-run", "TestNumbers$" })
  end)

  it("run latest", function()
    helpers.view(filename)
    vim.api.nvim_command "TestFile"
    assert.are.same(vim.g.test_latest.cmd, { "go", "test", "-v" })

    vim.api.nvim_command "TestLast"
    assert.are.same(vim.g.test_latest.cmd, { "go", "test", "-v" })
  end)
end)
