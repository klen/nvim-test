local helpers = require "spec.helpers"

describe("tsmocha", function()
  before_each(function()
    helpers.before_each { run = false, runners = { typescript = "nvim-test.runners.ts-mocha" } }
  end)
  after_each(helpers.after_each)

  local filename = "spec/fixtures/typescript/test.ts"

  it("run suite", function()
    helpers.view(filename)
    vim.api.nvim_command "TestSuite"
    assert.are.same({ "ts-mocha" }, vim.g.test_latest.cmd)
  end)

  it("run file", function()
    helpers.view(filename)
    vim.api.nvim_command "TestFile"
    assert.are.same({ "ts-mocha", filename }, vim.g.test_latest.cmd)
  end)

  it("run nearest function", function()
    helpers.view(filename, 6)
    vim.api.nvim_command "TestNearest"
    assert.are.same({ "ts-mocha", filename, "-f", "tstest ns test1" }, vim.g.test_latest.cmd)

    helpers.view(filename, 14)
    vim.api.nvim_command "TestNearest"
    assert.are.same({ "ts-mocha", filename, "-f", "mocha ns test2" }, vim.g.test_latest.cmd)
  end)

  it("run latest", function()
    helpers.view(filename)
    vim.api.nvim_command "TestFile"
    assert.are.same({ "ts-mocha", filename }, vim.g.test_latest.cmd)

    vim.api.nvim_command "TestLast"
    assert.are.same({ "ts-mocha", filename }, vim.g.test_latest.cmd)
  end)
end)
