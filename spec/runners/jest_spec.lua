-- Type: test
-- @spec: jest_spec.lua
-- @tags: jest
-- @description: Jest test runner

local helpers = require "spec.helpers"

describe("jest", function()
  before_each(helpers.before_each)
  after_each(helpers.after_each)

  local expected_testfile = "name.test.js"
  local expected_working_directory = "spec/fixtures/js"
  local filename = expected_working_directory .. "/" .. expected_testfile

  it("runner", function()
    local runner = require "nvim-test.runners.jest"
    assert.is.truthy(runner)
    assert.is.equal("jest", runner.config.command)

    assert.is_false(runner:is_testfile "somefile.js")
    assert.is_true(runner:is_testfile "somefile.spec.js")
    assert.is_true(runner:is_testfile "somefile.test.js")
    assert.is_true(runner:is_testfile "__tests__/somefile.js")

    assert.is.equal(filename, runner:find_file "spec/fixtures/js/name.js")
  end)

  it("run suite", function()
    helpers.view(filename)
    vim.api.nvim_command "TestSuite"
    assert.are.same({ "jest" }, vim.g.test_latest.cmd)
  end)

  it("run file", function()
    helpers.view(filename)
    vim.api.nvim_command "TestFile"
    assert.is.equal(expected_working_directory, vim.g.test_latest.cfg.working_directory)
    assert.are.same({ "jest", expected_testfile }, vim.g.test_latest.cmd)
  end)

  it("run nearest function", function()
    helpers.view(filename, 4)
    vim.api.nvim_command "TestNearest"
    assert.is.equal(expected_working_directory, vim.g.test_latest.cfg.working_directory)
    assert.are.same({ "jest", expected_testfile, "-t", "^jstest ns$" }, vim.g.test_latest.cmd)

    helpers.view(filename, 6)
    vim.api.nvim_command "TestNearest"
    assert.is.equal(expected_working_directory, vim.g.test_latest.cfg.working_directory)
    assert.are.same({ "jest", expected_testfile, "-t", "^jstest ns test1$" }, vim.g.test_latest.cmd)
  end)

  it("run latest", function()
    helpers.view(filename)
    vim.api.nvim_command "TestFile"
    assert.is.equal(expected_working_directory, vim.g.test_latest.cfg.working_directory)
    assert.are.same({ "jest", expected_testfile }, vim.g.test_latest.cmd)

    vim.api.nvim_command "TestLast"
    assert.is.equal(expected_working_directory, vim.g.test_latest.cfg.working_directory)
    assert.are.same({ "jest", expected_testfile }, vim.g.test_latest.cmd)
  end)
end)
