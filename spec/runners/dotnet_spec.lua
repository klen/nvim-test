local helpers = require "spec.helpers"
local pwd

describe("dotnet", function()
  before_each(function()
    helpers.before_each()
    pwd = vim.fn.getcwd()
    vim.api.nvim_command "cd spec/fixtures/dotnet"
  end)
  after_each(function()
    helpers.after_each()
    vim.api.nvim_command("cd " .. pwd)
  end)

  local filename = "Tests.cs"
  local filename2 = "Tests2.cs"
  local csproj = "proj.csproj"

  it("runner", function()
    local runner = require "nvim-test.runners.dotnet"
    assert.is.truthy(runner)
    assert.is.equal("dotnet", runner.config.command)
    assert.is.equal(".", runner.config.working_directory)
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
    -- test file with nested namespace
    helpers.view(filename)
    vim.api.nvim_command "TestFile"
    assert.are.same(
      { "dotnet", "test", "--filter",
        "FullyQualifiedName=Namespace.Tests.Test|Namespace.Tests.TestAsync|Namespace.Tests.TestAsyncWithTaskReturn" },
      vim.g.test_latest.cmd
    )
    -- test file with namespace defined globally for the whole file
    helpers.view(filename2)
    vim.api.nvim_command "TestFile"
    assert.are.same(
      { "dotnet", "test", "--filter",
        "FullyQualifiedName=Namespace2.Tests2.Test1|Namespace2.Tests2.Test2|Namespace2.Tests2.Test3" },
      vim.g.test_latest.cmd
    )
  end)

  it("run nearest function", function()
    helpers.view(filename, 4)
    vim.api.nvim_command "TestNearest"
    assert.are.same(
      { "dotnet", "test", "--filter", "FullyQualifiedName=Namespace.Tests.Test" },
      vim.g.test_latest.cmd
    )
    helpers.view(filename, 8)
    vim.api.nvim_command "TestNearest"
    assert.are.same(
      { "dotnet", "test", "--filter", "FullyQualifiedName=Namespace.Tests.Test" },
      vim.g.test_latest.cmd
    )
  end)

  it("run latest", function()
    helpers.view(filename)
    vim.api.nvim_command "TestFile"
    assert.are.same(
      { "dotnet", "test", "--filter",
        "FullyQualifiedName=Namespace.Tests.Test|Namespace.Tests.TestAsync|Namespace.Tests.TestAsyncWithTaskReturn" },
      vim.g.test_latest.cmd
    )

    vim.api.nvim_command "TestLast"
    assert.are.same(
      { "dotnet", "test", "--filter",
        "FullyQualifiedName=Namespace.Tests.Test|Namespace.Tests.TestAsync|Namespace.Tests.TestAsyncWithTaskReturn" },
      vim.g.test_latest.cmd
    )
  end)
end)
