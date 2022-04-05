local helpers = require "spec.helpers"

describe("nvim-test", function()
  after_each(helpers.after_each)
  before_each(helpers.before_each)

  it("test config", function()
    local nvim_test = require "nvim-test"
    nvim_test.setup { split = "abo split" }
    assert.are.equal(nvim_test.config.split, "abo split")
  end)

  it("test commands", function()
    assert.is_true(vim.fn.exists ":TestSuite" > 0)
    assert.is_true(vim.fn.exists ":TestFile" > 0)
    assert.is_true(vim.fn.exists ":TestNearest" > 0)
    assert.is_true(vim.fn.exists ":TestLast" > 0)
    assert.is_true(vim.fn.exists ":TestVisit" > 0)
  end)

  it("test visit", function()
    local filename = vim.fn.fnamemodify("spec/fixtures/test.lua", ":p")
    helpers.view(filename)
    vim.api.nvim_command "TestFile"
    helpers.view "unkwnown"
    vim.api.nvim_command "TestVisit"
    assert.buffer(filename)
  end)

  it("test edit", function()
    helpers.view "spec/fixtures/unknown.py"
    vim.api.nvim_command "TestEdit"
    assert.buffer(vim.fn.fnamemodify("spec/fixtures/test_unknown.py", ":p"))
  end)

  it("test suite", function()
    local filename = "spec/lua/test/fixtures/test.lua"
    helpers.view(filename)
    vim.api.nvim_command "TestFile"
    helpers.view "unkwnown"
    vim.api.nvim_command "TestSuite"
    assert.are.same(vim.g.test_latest.cmd, { "busted" })
  end)
end)
