local helpers = require "spec.lua.helpers"

describe("busted", function()
  before_each(helpers.before_each)
  after_each(helpers.after_each)

  local filename = "spec/lua/test/fixtures/test.lua"

  it("run suite", function()
    helpers.view(filename)
    vim.api.nvim_command "TestSuite"
    assert.are.same(vim.g.test_latest.cmd, { "busted" })
  end)

  it("run file", function()
    helpers.view(filename)
    vim.api.nvim_command "TestFile"
    assert.are.same(vim.g.test_latest.cmd, { "busted", filename })
  end)

  it("run nearest function", function()
    helpers.view(filename, 4)
    vim.api.nvim_command "TestNearest"
    assert.are.same(vim.g.test_latest.cmd, { "busted", filename, "--filter", "luatest test1" })
  end)

  it("run latest", function()
    helpers.view(filename)
    vim.api.nvim_command "TestFile"
    assert.are.same(vim.g.test_latest.cmd, { "busted", filename })

    vim.api.nvim_command "TestLast"
    assert.are.same(vim.g.test_latest.cmd, { "busted", filename })
  end)
end)
