--
return {
  autocommands_create = true,
  commands_create = true,
  silent = false,
  split = "vsplit",
  run = true,

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
