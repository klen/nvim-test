local helpers = require "spec.helpers"

describe("pyunit", function()
  before_each(function()
    helpers.before_each { run = false, runners = { python = "nvim-test.runners.pyunit" } }
  end)
  after_each(helpers.after_each)

  local filename = "spec/fixtures/test.py"

  it("runner", function()
    local runner = require "nvim-test.runners.pyunit"
    assert.is.truthy(runner)

    assert.is_false(runner:is_testfile "somefile.py")
    assert.is_true(runner:is_testfile "test_somefile.py")
  end)

  it("run suite", function()
    helpers.view(filename)
    vim.api.nvim_command "TestSuite"
    assert.are.same(vim.g.test_latest.cmd, { "python", "-m", "unittest" })
  end)

  it("run file", function()
    helpers.view(filename)
    vim.api.nvim_command "TestFile"
    assert.are.same(vim.g.test_latest.cmd, { "python", "-m", "unittest", "spec.fixtures.test" })
  end)

  it("run nearest function", function()
    helpers.view(filename, 4)
    vim.api.nvim_command "TestNearest"
    assert.are.same(
      vim.g.test_latest.cmd,
      { "python", "-m", "unittest", "spec.fixtures.test.test_base" }
    )
  end)

  it("run nearest method", function()
    helpers.view(filename, 13)
    vim.api.nvim_command "TestNearest"
    assert.are.same(
      vim.g.test_latest.cmd,
      { "python", "-m", "unittest", "spec.fixtures.test.MyTest.test_method2" }
    )
  end)

  it("run latest", function()
    helpers.view(filename)
    vim.api.nvim_command "TestFile"
    assert.are.same(vim.g.test_latest.cmd, { "python", "-m", "unittest", "spec.fixtures.test" })

    vim.api.nvim_command "TestLast"
    assert.are.same(vim.g.test_latest.cmd, { "python", "-m", "unittest", "spec.fixtures.test" })
  end)
end)
