describe("runner", function()
  it("test runners", function()
    local nvim_test = require "nvim-test"
    local runner = nvim_test.get_runner "javascript"
    assert.are.equal(runner.config.command, "jest")

    nvim_test.setup { runners = { javascript = "nvim-test.runners.mocha" } }
    assert.are.equal(nvim_test.config.runners.javascript, "nvim-test.runners.mocha")

    runner = nvim_test.get_runner "javascript"
    assert.are.equal(runner.config.command, "mocha")
  end)
end)
