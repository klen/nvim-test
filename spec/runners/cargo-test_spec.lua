local helpers = require "spec.helpers"

describe("cargotest", function()
  before_each(function()
    helpers.before_each()
    vim.api.nvim_command "cd spec/fixtures/rust/crate"
  end)
  after_each(function()
    helpers.after_each()
    vim.api.nvim_command "cd -"
  end)

  it("run suite", function()
    helpers.view "src/main.rs"
    vim.api.nvim_command "TestSuite"
    assert.are.same({ "cargo", "test" }, vim.g.test_latest.cmd)
  end)

  it("run file", function()
    helpers.view "src/main.rs"
    vim.api.nvim_command "TestFile"
    assert.are.same({ "cargo", "test" }, vim.g.test_latest.cmd)

    helpers.view "src/somemod.rs"
    vim.api.nvim_command "TestFile"
    assert.are.same({ "cargo", "test", "somemod::" }, vim.g.test_latest.cmd)

    helpers.view "src/nested/mod.rs"
    vim.api.nvim_command "TestFile"
    assert.are.same({ "cargo", "test", "nested::" }, vim.g.test_latest.cmd)
  end)

  it("run nearest function", function()
    helpers.view("src/lib.rs", 7)
    assert.exists_pattern "first_test"
    vim.api.nvim_command "TestNearest"
    assert.are.same(
      { "cargo", "test", "tests::first_test", "--", "--exact" },
      vim.g.test_latest.cmd
    )
  end)

  it("run latest", function()
    helpers.view "src/main.rs"
    vim.api.nvim_command "TestFile"
    assert.are.same({ "cargo", "test" }, vim.g.test_latest.cmd)

    vim.api.nvim_command "TestLast"
    assert.are.same({ "cargo", "test" }, vim.g.test_latest.cmd)
  end)
end)
