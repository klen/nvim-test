local helpers = require "spec.lua.helpers"

describe("pyunit", function()
  before_each(function()
    helpers.before_each { run = false, runners = { python = "nvim-test.runners.pyunit" } }
  end)
  after_each(helpers.after_each)

  local filename = "spec/lua/test/fixtures/test.py"

  it("run suite", function()
    helpers.view(filename)
    vim.api.nvim_command "TestSuite"
    assert.are.same(vim.g.test_latest.cmd, { "python", "-m", "unittest" })
  end)

  it("run file", function()
    helpers.view(filename)
    vim.api.nvim_command "TestFile"
    assert.are.same(
      vim.g.test_latest.cmd,
      { "python", "-m", "unittest", "spec.lua.test.fixtures.test" }
    )
  end)

  it("run nearest function", function()
    helpers.view(filename, 4)
    vim.api.nvim_command "TestNearest"
    assert.are.same(
      vim.g.test_latest.cmd,
      { "python", "-m", "unittest", "spec.lua.test.fixtures.test.test_base" }
    )
  end)

  it("run nearest method", function()
    helpers.view(filename, 13)
    vim.api.nvim_command "TestNearest"
    assert.are.same(
      vim.g.test_latest.cmd,
      { "python", "-m", "unittest", "spec.lua.test.fixtures.test.MyTest.test_method2" }
    )
  end)

  it("run latest", function()
    helpers.view(filename)
    vim.api.nvim_command "TestFile"
    assert.are.same(
      vim.g.test_latest.cmd,
      { "python", "-m", "unittest", "spec.lua.test.fixtures.test" }
    )

    vim.api.nvim_command "TestLast"
    assert.are.same(
      vim.g.test_latest.cmd,
      { "python", "-m", "unittest", "spec.lua.test.fixtures.test" }
    )
  end)
end)
