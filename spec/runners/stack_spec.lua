local helpers = require "spec.helpers"

describe("hspec", function()
  before_each(helpers.before_each)
  after_each(helpers.after_each)

  local filename = "spec/fixtures/Spec.hs"

  it("run suite", function()
    helpers.view(filename)
    vim.api.nvim_command "TestSuite"
    assert.are.same({ "stack", "test" }, vim.g.test_latest.cmd)
  end)

  it("run file", function()
    helpers.view(filename)
    vim.api.nvim_command "TestFile"
    assert.are.same({ "stack", "test", filename }, vim.g.test_latest.cmd)
  end)

  it("run nearest function", function()
    helpers.view(filename, 16)
    vim.api.nvim_command "TestNearest"
    assert.are.same({
      "stack",
      "test",
      filename,
      "--test-arguments='--match \"Prelude.head/nested/throws an exception if used with an empty list\"'",
    }, vim.g.test_latest.cmd)
  end)

  it("run latest", function()
    helpers.view(filename)
    vim.api.nvim_command "TestFile"
    assert.are.same({ "stack", "test", filename }, vim.g.test_latest.cmd)

    vim.api.nvim_command "TestLast"
    assert.are.same({ "stack", "test", filename }, vim.g.test_latest.cmd)
  end)
end)
