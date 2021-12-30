require "spec.lua.conftest"
print(999, vim.inspect(vim.fn.split(package.path), ";"))

local helpers = require "spec.lua.helpers"

describe("busted", function()
  before_each(helpers.before_each)
  after_each(helpers.after_each)

  local filename = vim.fn.fnamemodify("spec/lua/test/fixtures/test.lua", ":p")

  it("run suite", function()
    helpers.view(filename)
    vim.api.nvim_command "TestSuite"
    assert.are.equal("busted", vim.g.nvim_last)
  end)

  it("run file", function()
    helpers.view(filename)
    vim.api.nvim_command "TestFile"
    assert.are.equal("busted " .. filename, vim.g.nvim_last)
  end)

  it("run nearest function", function()
    helpers.view(filename, 4)
    vim.api.nvim_command "TestNearest"
    assert.are.equal("busted " .. filename .. " --filter 'luatest test1'", vim.g.nvim_last)
  end)

  it("run latest", function()
    helpers.view(filename)
    vim.api.nvim_command "TestFile"
    assert.are.equal("busted " .. filename, vim.g.nvim_last)

    vim.api.nvim_command "TestLast"
    assert.are.equal("busted " .. filename, vim.g.nvim_last)
  end)
end)
