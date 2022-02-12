--
return {
  commands_create = true,
  silent = false,

  run = true,
  split = "vsplit",
  cmd = "terminal %s",
  -- cmd = 'TermExec cmd="%s"',

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
