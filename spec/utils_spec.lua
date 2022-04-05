describe("utils", function()
  local utils = require "nvim-test.utils"
  it("find file by patterns", function()
    assert.is.equal(
      "spec/fixtures/js/name.test.js",
      utils.find_file_by_patterns(
        "spec/fixtures/js/name.js",
        { "{name}.spec.{ext}", "{name}.test.{ext}" }
      )
    )
    assert.is.equal(
      "spec/fixtures/js/unknown.js",
      utils.find_file_by_patterns(
        "spec/fixtures/js/unknown.js",
        { "{name}.spec.{ext}", "{name}.test.{ext}" }
      )
    )
    assert.is.equal(
      "spec/fixtures/js/unknown.spec.js",
      utils.find_file_by_patterns(
        "spec/fixtures/js/unknown.js",
        { "{name}.spec.{ext}", "{name}.test.{ext}" },
        true
      )
    )
  end)
end)
