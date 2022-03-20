local helpers = require "spec.lua.helpers"

describe("cargotest", function()
  before_each(function()
    helpers.before_each()
    vim.api.nvim_command "cd spec/lua/test/fixtures/rust/crate"
  end)
  after_each(function()
    helpers.after_each()
    vim.api.nvim_command "cd -"
  end)

  it("run suite", function()
    helpers.view "src/main.rs"
    vim.api.nvim_command "TestSuite"
    assert.are.equal(vim.g.test_latest.cmd, "cargo test")
  end)

  it("run file", function()
    helpers.view "src/main.rs"
    vim.api.nvim_command "TestFile"
    assert.are.equal(vim.g.test_latest.cmd, "cargo test")

    helpers.view "src/somemod.rs"
    vim.api.nvim_command "TestFile"
    assert.are.equal(vim.g.test_latest.cmd, "cargo test 'somemod::'")

    helpers.view "src/nested/mod.rs"
    vim.api.nvim_command "TestFile"
    assert.are.equal(vim.g.test_latest.cmd, "cargo test 'nested::'")
  end)

  it("run nearest function", function()
    helpers.view("src/lib.rs", 4)
    assert.exists_pattern "first_test"
    vim.api.nvim_command "TestNearest"
    assert.are.equal(vim.g.test_latest.cmd, "cargo test tests::first_test -- --exact")
  end)

  it("run latest", function()
    helpers.view "src/main.rs"
    vim.api.nvim_command "TestFile"
    assert.are.equal(vim.g.test_latest.cmd, "cargo test")

    vim.api.nvim_command "TestLast"
    assert.are.equal(vim.g.test_latest.cmd, "cargo test")
  end)
end)
