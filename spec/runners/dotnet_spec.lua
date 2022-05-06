local helpers = require "spec.helpers"

describe("dotnet", function()
  before_each(helpers.before_each)
  after_each(helpers.after_each)

  local filename = "spec/fixtures/Tests.cs"

  it("runner", function()
    local runner = require "nvim-test.runners.dotnet"
    assert.is.truthy(runner)
    assert.is.equal("dotnet", runner.config.command)
    --
    assert.is_false(runner:is_testfile "somefile.cs")
    assert.is_true(runner:is_testfile "test/somefile.cs")
    assert.is_true(runner:is_testfile "Tests.cs")
  end)

  it("run suite", function()
    helpers.view(filename)
    vim.api.nvim_command "TestSuite"
    assert.are.same({ "dotnet", "test" }, vim.g.test_latest.cmd)
  end)

  it("run file", function()
    helpers.view(filename)
    vim.api.nvim_command "TestFile"
    assert.are.same({ "dotnet", "test", filename }, vim.g.test_latest.cmd)
  end)

  it("run nearest function", function()
    helpers.view(filename, 4)
    vim.api.nvim_command "TestNearest"
    assert.are.same(
      { "dotnet", "test", filename, "--filter", "FullyQualifiedName=Namespace.Tests" },
      vim.g.test_latest.cmd
    )
    helpers.view(filename, 8)
    vim.api.nvim_command "TestNearest"
    assert.are.same(
      { "dotnet", "test", filename, "--filter", "FullyQualifiedName=Namespace.Tests.Test" },
      vim.g.test_latest.cmd
    )
  end)

  it("run latest", function()
    helpers.view(filename)
    vim.api.nvim_command "TestFile"
    assert.are.same({ "dotnet", "test", filename }, vim.g.test_latest.cmd)

    vim.api.nvim_command "TestLast"
    assert.are.same({ "dotnet", "test", filename }, vim.g.test_latest.cmd)
  end)
end)
