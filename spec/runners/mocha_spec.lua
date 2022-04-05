local helpers = require "spec.helpers"

describe("mocha", function()
  before_each(function()
    helpers.before_each { run = false, runners = { javascript = "nvim-test.runners.mocha" } }
  end)
  after_each(helpers.after_each)

  local filename = "spec/fixtures/js/name.test.js"

  it("runner", function()
    local runner = require "nvim-test.runners.mocha"
    assert.is.truthy(runner)

    assert.is_false(runner:is_testfile "somefile.js")
    assert.is_true(runner:is_testfile "somefile.test.js")
    assert.is_true(runner:is_testfile "test/somefile.js")
  end)

  it("run suite", function()
    helpers.view(filename)
    vim.api.nvim_command "TestSuite"
    assert.are.same(vim.g.test_latest.cmd, { "mocha" })
  end)

  it("run file", function()
    helpers.view(filename)
    vim.api.nvim_command "TestFile"
    assert.are.same(vim.g.test_latest.cmd, { "mocha", filename })
  end)

  it("run nearest function", function()
    helpers.view(filename, 4)
    vim.api.nvim_command "TestNearest"
    assert.are.same(vim.g.test_latest.cmd, { "mocha", filename, "-f", "jstest ns test1" })
  end)

  it("run latest", function()
    helpers.view(filename)
    vim.api.nvim_command "TestFile"
    assert.are.same(vim.g.test_latest.cmd, { "mocha", filename })

    vim.api.nvim_command "TestLast"
    assert.are.same(vim.g.test_latest.cmd, { "mocha", filename })
  end)
end)
