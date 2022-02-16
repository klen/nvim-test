--
return {
  commands_create = true,
  silent = false,

  run = true,
  term = "terminal",
  termOpts = {
    direction = "vertical",
    width = 96,
    height = 24,
    go_back = false,
    stopinsert = false,
  },

  -- Supported runnners
  runners = {
    go = "nvim-test.runners.go-test",
    javascript = "nvim-test.runners.jest",
    lua = "nvim-test.runners.busted",
    python = "nvim-test.runners.pytest",
    rust = "nvim-test.runners.cargo-test",
    typescript = "nvim-test.runners.jest",
  },
}
