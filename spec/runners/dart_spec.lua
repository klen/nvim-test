local helpers = require "spec.helpers"

describe("dart", function()
  before_each(helpers.before_each)
  after_each(helpers.after_each)

  local filename = "spec/fixtures/dart/math_test.dart"

  it("runner", function()
    local runner = require "nvim-test.runners.dart"
    assert.is.truthy(runner)

    assert.is_false(runner:is_testfile "somefile.dart")
    assert.is_true(runner:is_testfile "somefile_test.dart")
  end)

  it("run suite", function()
    helpers.view(filename)
    vim.api.nvim_command "TestSuite"
    assert.are.same({ "dart", "test" }, vim.g.test_latest.cmd)
  end)

  it("run file", function()
    helpers.view(filename)
    vim.api.nvim_command "TestFile"
    assert.are.same({ "dart", "test", filename }, vim.g.test_latest.cmd)
  end)

  it("run latest", function()
    helpers.view(filename)
    vim.api.nvim_command "TestFile"
    assert.are.same({ "dart", "test", filename }, vim.g.test_latest.cmd)

    vim.api.nvim_command "TestLast"
    assert.are.same({ "dart", "test", filename }, vim.g.test_latest.cmd)
  end)
end)
