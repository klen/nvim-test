local helpers = require "spec.helpers"
local pwd

describe("rspec", function()
  before_each(function()
    helpers.before_each()
    pwd = vim.fn.getcwd()
    -- this skips discovery of command that is installed on the host
    -- we should not be dependent on what's on the host in tests
    local runner = require("nvim-test").get_runner("ruby")
    runner.config.command = "bundle"
    vim.api.nvim_command("cd spec/fixtures/ruby")
  end)
  after_each(function()
    helpers.after_each()
    vim.api.nvim_command("cd " .. pwd)
  end)

  local filename = "spec/test_spec.rb"

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
    helpers.view(filename, 5)
    vim.api.nvim_command "TestNearest"
    assert.are.same({
      "bundle",
      "exec",
      "rspec",
      filename,
      "--example",
      "'#score returns 0 for an all gutter game'",
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
