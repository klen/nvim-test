local helpers = require "spec.helpers"

describe("rspec", function()
  before_each(helpers.before_each)
  after_each(helpers.after_each)

  local filename = "spec/fixtures/test_spec.rb"

  it("run suite", function()
    helpers.view(filename)
    vim.api.nvim_command "TestSuite"
    assert.are.same({ "bundle", "exec", "rspec" }, vim.g.test_latest.cmd)
  end)

  it("run file", function()
    helpers.view(filename)
    vim.api.nvim_command "TestFile"
    assert.are.same({ "bundle", "exec", "rspec", filename }, vim.g.test_latest.cmd)
  end)

  it("run nearest function", function()
    helpers.view(filename, 4)
    vim.api.nvim_command "TestNearest"
    assert.are.same({
      "bundle",
      "exec",
      "rspec",
      filename,
      "--example",
      "#score returns 0 for an all gutter game",
    }, vim.g.test_latest.cmd)
  end)

  it("run latest", function()
    helpers.view(filename)
    vim.api.nvim_command "TestFile"
    assert.are.same({ "bundle", "exec", "rspec", filename }, vim.g.test_latest.cmd)

    vim.api.nvim_command "TestLast"
    assert.are.same({ "bundle", "exec", "rspec", filename }, vim.g.test_latest.cmd)
  end)
end)
