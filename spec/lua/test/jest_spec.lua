local helpers = require "spec.lua.helpers"

describe("jest", function()
  before_each(helpers.before_each)
  after_each(helpers.after_each)

  local filename = vim.fn.fnamemodify("spec/lua/test/fixtures/test.js", ":p")

  it("run suite", function()
    helpers.view(filename)
    vim.api.nvim_command "TestSuite"
    assert.are.equal(vim.g.test_latest.cmd, "jest")
  end)

  it("run file", function()
    helpers.view(filename)
    vim.api.nvim_command "TestFile"
    assert.are.equal(vim.g.test_latest.cmd, "jest " .. filename)
  end)

  it("run nearest function", function()
    helpers.view(filename, 4)
    vim.api.nvim_command "TestNearest"
    assert.are.equal(vim.g.test_latest.cmd, "jest " .. filename .. " -t 'jstest ns test1'")
  end)

  it("run latest", function()
    helpers.view(filename)
    vim.api.nvim_command "TestFile"
    assert.are.equal(vim.g.test_latest.cmd, "jest " .. filename)

    vim.api.nvim_command "TestLast"
    assert.are.equal(vim.g.test_latest.cmd, "jest " .. filename)
  end)
end)
