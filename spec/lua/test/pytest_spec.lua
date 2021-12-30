local helpers = require "spec.lua.helpers"

describe("pytest", function()
  before_each(helpers.before_each)
  after_each(helpers.after_each)

  local filename = vim.fn.fnamemodify("spec/lua/test/fixtures/test.py", ":p")

  it("run suite", function()
    helpers.view(filename)
    vim.api.nvim_command "TestSuite"
    assert.are.equal("pytest", vim.g.nvim_last)
  end)

  it("run file", function()
    helpers.view(filename)
    vim.api.nvim_command "TestFile"
    assert.are.equal("pytest " .. filename, vim.g.nvim_last)
  end)

  it("run nearest function", function()
    helpers.view(filename, 4)
    vim.api.nvim_command "TestNearest"
    assert.are.equal("pytest " .. filename .. "::test_base", vim.g.nvim_last)
  end)

  it("run nearest method", function()
    helpers.view(filename, 13)
    vim.api.nvim_command "TestNearest"
    assert.are.equal("pytest " .. filename .. "::MyTest::test_method2", vim.g.nvim_last)
  end)

  it("run latest", function()
    helpers.view(filename)
    vim.api.nvim_command "TestFile"
    assert.are.equal("pytest " .. filename, vim.g.nvim_last)

    vim.api.nvim_command "TestLast"
    assert.are.equal("pytest " .. filename, vim.g.nvim_last)
  end)
end)
