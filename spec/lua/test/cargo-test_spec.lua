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
    assert.are.equal("cargo test", vim.g.nvim_last)
  end)

  it("run file", function()
    helpers.view "src/main.rs"
    vim.api.nvim_command "TestFile"
    assert.are.equal("cargo test", vim.g.nvim_last)

    helpers.view "src/somemod.rs"
    vim.api.nvim_command "TestFile"
    assert.are.equal("cargo test 'somemod::'", vim.g.nvim_last)

    helpers.view "src/nested/mod.rs"
    vim.api.nvim_command "TestFile"
    assert.are.equal("cargo test 'nested::'", vim.g.nvim_last)
  end)

  it("run nearest function", function()
    helpers.view("src/lib.rs", 4)
    assert.exists_pattern "first_test"
    vim.api.nvim_command "TestNearest"
    assert.are.equal("cargo test tests::first_test -- --exact", vim.g.nvim_last)
  end)

  it("run latest", function()
    helpers.view "src/main.rs"
    vim.api.nvim_command "TestFile"
    assert.are.equal("cargo test", vim.g.nvim_last)

    vim.api.nvim_command "TestLast"
    assert.are.equal("cargo test", vim.g.nvim_last)
  end)
end)
