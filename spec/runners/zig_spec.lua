local helpers = require("spec.helpers")

describe("zigtest", function()
  before_each(function()
    helpers.before_each()
    vim.api.nvim_command("cd spec/fixtures/zig")
  end)
  after_each(function()
    helpers.after_each()
    vim.api.nvim_command("cd -")
  end)

  it("run suite", function()
    helpers.view("src/main.zig")
    vim.api.nvim_command("TestSuite")
    assert.are.same(vim.g.test_latest.cmd, { "zig", "build", "test" })
  end)

  it("run file", function()
    helpers.view("src/main.zig")
    vim.api.nvim_command("TestFile")
    assert.are.same(vim.g.test_latest.cmd, { "zig", "test", "src/main.zig" })

    helpers.view("src/somemod.zig")
    vim.api.nvim_command("TestFile")
    assert.are.same(vim.g.test_latest.cmd, { "zig", "test", "src/somemod.zig" })

    helpers.view("src/nested/mod.zig")
    vim.api.nvim_command("TestFile")
    assert.are.same(vim.g.test_latest.cmd, { "zig", "test", "src/nested/mod.zig" })
  end)

  it("run nearest function", function()
    helpers.view("src/main.zig", 8)
    -- assert.exists_pattern("first_test")
    vim.api.nvim_command("TestNearest")
    assert.are.same(
      { "zig", "test", "src/main.zig", "--test-filter", "basic add functionality" },
      vim.g.test_latest.cmd
    )
  end)

  it("run latest", function()
    helpers.view("src/main.zig")
    vim.api.nvim_command("TestFile")
    assert.are.same(vim.g.test_latest.cmd, { "zig", "test", "src/main.zig" })

    vim.api.nvim_command("TestLast")
    assert.are.same(vim.g.test_latest.cmd, { "zig", "test", "src/main.zig" })
  end)
end)
