local helpers = require "spec.lua.helpers"

describe("nvim-test", function()
  after_each(helpers.after_each)
  before_each(helpers.before_each)

  it("test config", function()
    local nvim_test = require "nvim-test"
    nvim_test.setup { split = "abo split" }
    assert.are.equal(nvim_test.config.split, "abo split")
  end)

  it("test commands", function()
    assert.is_true(vim.fn.exists ":TestSuite" > 0)
    assert.is_true(vim.fn.exists ":TestFile" > 0)
    assert.is_true(vim.fn.exists ":TestNearest" > 0)
    assert.is_true(vim.fn.exists ":TestLast" > 0)
  end)
end)
