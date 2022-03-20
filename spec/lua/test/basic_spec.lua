local helpers = require "spec.lua.helpers"

describe("nvim-test", function()
  after_each(helpers.after_each)
  before_each(helpers.before_each)

  it("test config", function()
    local nvim_test = require "nvim-test"
    nvim_test.setup { split = "abo split" }
    assert.are.equal(nvim_test.config.split, "abo split")
  end)

  it("test runners", function()
    local nvim_test = require "nvim-test"
    local runner = nvim_test.get_runner "javascript"
    assert.are.equal(runner.config.command, "jest")

    nvim_test.setup { runners = { javascript = "nvim-test.runners.mocha" } }
    assert.are.equal(nvim_test.config.runners.javascript, "nvim-test.runners.mocha")

    runner = nvim_test.get_runner "javascript"
    assert.are.equal(runner.config.command, "mocha")
  end)

  it("test commands", function()
    assert.is_true(vim.fn.exists ":TestSuite" > 0)
    assert.is_true(vim.fn.exists ":TestFile" > 0)
    assert.is_true(vim.fn.exists ":TestNearest" > 0)
    assert.is_true(vim.fn.exists ":TestLast" > 0)
    assert.is_true(vim.fn.exists ":TestVisit" > 0)
  end)

  it("test unkwnown", function()
    helpers.view "unkwnown"
    vim.api.nvim_command "TestSuite"
    assert.exists_message "is not found"
  end)

  it("test visit", function()
    local filename = vim.fn.fnamemodify("spec/lua/test/fixtures/test.lua", ":p")
    helpers.view(filename)
    vim.api.nvim_command "TestFile"
    helpers.view "unkwnown"
    vim.api.nvim_command "TestVisit"
    assert.buffer(filename)
  end)

  it("test suite", function()
    local filename = vim.fn.fnamemodify("spec/lua/test/fixtures/test.lua", ":p")
    helpers.view(filename)
    vim.api.nvim_command "TestFile"
    helpers.view "unkwnown"
    vim.api.nvim_command "TestSuite"
    assert.are.equal(vim.g.test_latest.cmd, "busted")
  end)
end)
