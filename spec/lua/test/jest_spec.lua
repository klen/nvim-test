require "spec.lua.conftest"

local helpers = require "spec.lua.helpers"

describe("jest", function()
  before_each(helpers.before_each)
  after_each(helpers.after_each)

  local filename = vim.fn.fnamemodify("spec/lua/test/fixtures/test.js", ":p")

  it("run suite", function()
    helpers.view(filename)
    vim.api.nvim_command "TestSuite"
    assert.are.equal("jest", vim.g.nvim_last)
  end)

  it("run file", function()
    helpers.view(filename)
    vim.api.nvim_command "TestFile"
    assert.are.equal("jest " .. filename, vim.g.nvim_last)
  end)

  it("run nearest function", function()
    helpers.view(filename, 4)
    vim.api.nvim_command "TestNearest"
    assert.are.equal("jest " .. filename .. " -t 'jstest ns test1'", vim.g.nvim_last)
  end)

  it("run latest", function()
    helpers.view(filename)
    vim.api.nvim_command "TestFile"
    assert.are.equal(vim.g.nvim_last, "jest " .. filename)

    vim.api.nvim_command "TestLast"
    assert.are.equal(vim.g.nvim_last, "jest " .. filename)
  end)
end)
