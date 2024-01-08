local helpers = require "spec.helpers"

describe("dotnet", function()
  before_each(function()
    helpers.before_each()
  end)
  after_each(function()
    helpers.after_each()
  end)

  local filename = "spec/fixtures/dotnet/subfolder/Tests.cs"
  local filename2 = "spec/fixtures/dotnet/subfolder/Tests2.cs"
  local expected_working_directory = "spec/fixtures/dotnet";
  local expected_csproj = "spec/fixtures/dotnet/proj.csproj"

  it("runner", function()
    local runner = require "nvim-test.runners.dotnet"
    assert.is.truthy(runner)
    assert.is.equal("dotnet", runner.config.command)
    -- assert.is.equal(".", runner:find_working_directory(filename))

    assert.is_false(runner:is_testfile("somefile.cs"))
    assert.is_true(runner:is_testfile("test/somefile.cs"))
    assert.is_true(runner:is_testfile("Tests.cs"))
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
    assert.is.equal(expected_working_directory, vim.g.test_latest.cfg.working_directory)
    assert.are.same(
      { "dotnet", "test", "--filter",
        "FullyQualifiedName=Namespace.Tests.Test|Namespace.Tests.TestAsync|Namespace.Tests.TestAsyncWithTaskReturn" },
      vim.g.test_latest.cmd
    )
    -- test file with namespace defined globally for the whole file
    helpers.view(filename2)
    vim.api.nvim_command "TestFile"
    assert.is.equal(expected_working_directory, vim.g.test_latest.cfg.working_directory)
    assert.are.same(
      { "dotnet", "test", "--filter",
        "FullyQualifiedName=Namespace2.Tests2.Test1|Namespace2.Tests2.Test2|Namespace2.Tests2.Test3" },
      vim.g.test_latest.cmd
    )
  end)

  it("run nearest function", function()
    helpers.view(filename, 4)
    vim.api.nvim_command "TestNearest"
    assert.is.equal(expected_working_directory, vim.g.test_latest.cfg.working_directory)
    assert.are.same(
      { "dotnet", "test", "--filter", "FullyQualifiedName=Namespace.Tests.Test" },
      vim.g.test_latest.cmd
    )
    helpers.view(filename, 8)
    vim.api.nvim_command "TestNearest"
    assert.is.equal(expected_working_directory, vim.g.test_latest.cfg.working_directory)
    assert.are.same(
      { "dotnet", "test", "--filter", "FullyQualifiedName=Namespace.Tests.Test" },
      vim.g.test_latest.cmd
    )
  end)

  it("run latest", function()
    helpers.view(filename)
    vim.api.nvim_command "TestFile"
    assert.is.equal(expected_working_directory, vim.g.test_latest.cfg.working_directory)
    assert.are.same(
      { "dotnet", "test", "--filter",
        "FullyQualifiedName=Namespace.Tests.Test|Namespace.Tests.TestAsync|Namespace.Tests.TestAsyncWithTaskReturn" },
      vim.g.test_latest.cmd
    )

    vim.api.nvim_command "TestLast"
    assert.is.equal(expected_working_directory, vim.g.test_latest.cfg.working_directory)
    assert.are.same(
      { "dotnet", "test", "--filter",
        "FullyQualifiedName=Namespace.Tests.Test|Namespace.Tests.TestAsync|Namespace.Tests.TestAsyncWithTaskReturn" },
      vim.g.test_latest.cmd
    )
  end)
end)
