local helpers = require "spec.lua.helpers"

describe("tsmocha", function()
  before_each(function()
    helpers.before_each { run = false, runners = { typescript = "nvim-test.runners.ts-mocha" } }
  end)
  after_each(helpers.after_each)

  local filename = vim.fn.fnamemodify("spec/lua/test/fixtures/test.ts", ":p")

  it("run suite", function()
    helpers.view(filename)
    vim.api.nvim_command "TestSuite"
    assert.are.equal(vim.g.test_latest.cmd, "ts-mocha")
  end)

  it("run file", function()
    helpers.view(filename)
    vim.api.nvim_command "TestFile"
    assert.are.equal(vim.g.test_latest.cmd, "ts-mocha " .. filename)
  end)

  it("run nearest function", function()
    helpers.view(filename, 4)
    vim.api.nvim_command "TestNearest"
    assert.are.equal(vim.g.test_latest.cmd, "ts-mocha " .. filename .. " -f 'tstest ns test1'")
  end)

  it("run latest", function()
    helpers.view(filename)
    vim.api.nvim_command "TestFile"
    assert.are.equal(vim.g.test_latest.cmd, "ts-mocha " .. filename)

    vim.api.nvim_command "TestLast"
    assert.are.equal(vim.g.test_latest.cmd, "ts-mocha " .. filename)
  end)
end)
