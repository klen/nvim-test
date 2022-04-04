require("nvim-test").setup {
  runners = {
    lua = "nvim-test.runners.vusted",
  },
}

require("nvim-test.runners.vusted"):setup {
  args = { "--helper=spec/lua/conftest.lua" },
  env = {
    VIRTUAL_ENV = "",
    VUSTED_ARGS = "--headless --clean",
  },

  find_spec = function(filename)
    local test_pattern = "_spec.lua"
    if filename:sub(-#test_pattern) == test_pattern then
      return filename
    end

    return string.format("spec/lua/test/%s_spec.lua", vim.fn.fnamemodify(filename, ":t:r"))
  end,
}
