require("nvim-test").setup {
  runners = {
    lua = "nvim-test.runners.vusted",
  },
}

require("nvim-test.runners.vusted"):setup {
  args = { "--helper=spec/conftest.lua" },
  env = {
    VIRTUAL_ENV = "",
    VUSTED_ARGS = "--headless --clean",
  },

  find_files = function(filename)
    local path, _ = vim.fn.fnamemodify(filename, ":p:h"):gsub("lua/nvim%-test", "spec")
    return string.format("%s/%s_spec.lua", path, vim.fn.fnamemodify(filename, ":t:r"))
  end,
}
