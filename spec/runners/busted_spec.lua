local helpers = require "spec.helpers"

describe("busted", function()
  before_each(helpers.before_each)
  after_each(helpers.after_each)

  local filename = "spec/fixtures/test.lua"

  it("runner", function()
    local runner = require "nvim-test.runners.busted"
    assert.is.truthy(runner)

    assert.is_false(runner:is_testfile "somefile.lua")
    assert.is_true(runner:is_testfile "somefile_spec.lua")
    assert.is_true(runner:is_testfile "somefile_spec.moon")
  end)

  it("run suite", function()
    helpers.view(filename)
    vim.api.nvim_command "TestSuite"
    assert.are.same({ "busted" }, vim.g.test_latest.cmd)
  end)

  it("run file", function()
    helpers.view(filename)
    vim.api.nvim_command "TestFile"
    assert.are.same({ "busted", filename }, vim.g.test_latest.cmd)
  end)

  it("run nearest function", function()
    helpers.view(filename, 4)
    vim.api.nvim_command "TestNearest"
    assert.are.same({ "busted", filename, "--filter", "test1" }, vim.g.test_latest.cmd)
  end)

  it("run latest", function()
    helpers.view(filename)
    vim.api.nvim_command "TestFile"
    assert.are.same({ "busted", filename }, vim.g.test_latest.cmd)

    vim.api.nvim_command "TestLast"
    assert.are.same({ "busted", filename }, vim.g.test_latest.cmd)
  end)
end)
