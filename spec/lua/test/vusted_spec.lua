local helpers = require "spec.lua.helpers"

describe("vusted", function()
  before_each(function()
    helpers.before_each { run = false, runners = { lua = "nvim-test.runners.vusted" } }
  end)
  after_each(helpers.after_each)

  require("nvim-test").setup { runners = { lua = "nvim-test.runners.vusted" } }

  local filename = "spec/lua/test/fixtures/test.lua"

  it("run suite", function()
    helpers.view(filename)
    vim.api.nvim_command "TestSuite"
    assert.are.same({ "vusted" }, vim.g.test_latest.cmd)
  end)

  it("run file", function()
    helpers.view(filename)
    vim.api.nvim_command "TestFile"
    assert.are.same({ "vusted", filename }, vim.g.test_latest.cmd)
  end)

  it("run nearest function", function()
    helpers.view(filename, 4)
    vim.api.nvim_command "TestNearest"
    assert.are.same({ "vusted", filename, "--filter", "luatest test1" }, vim.g.test_latest.cmd)
  end)

  it("run latest", function()
    helpers.view(filename)
    vim.api.nvim_command "TestFile"
    assert.are.same({ "vusted", filename }, vim.g.test_latest.cmd)

    vim.api.nvim_command "TestLast"
    assert.are.same({ "vusted", filename }, vim.g.test_latest.cmd)
  end)
end)
