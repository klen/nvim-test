<img src="https://neovim.io/logos/neovim-mark-flat.png" align="right" width="144" />

# nvim-test 0.4.1

Test Runner for neovim

[![tests](https://github.com/klen/nvim-test/actions/workflows/tests.yml/badge.svg)](https://github.com/klen/nvim-test/actions/workflows/tests.yml)
[![Awesome Neovim](https://awesome.re/badge-flat.svg)](https://github.com/rockerBOO/awesome-neovim)


## Features

| Language       | Test Runners                     |
| -------------: | :------------------------------- |
| **Go**         | Go `go-test`                     |
| **Javascript** | Mocha `mocha`, Jest `jest`       |
| **Lua**        | Busted `busted`                  |
| **Python**     | PyTest `pytest`, PyUnit `pyunit` |
| **Rust**       | Cargo `cargo-test`               |
| **Typescript** | TS-Mocha `ts-mocha`              |

## Install

with [packer](https://github.com/wbthomason/packer.nvim):

```lua

use {
  "klen/nvim-test",
  config = function()
    require('nvim-test').setup()
  end
}
```

## Commands

The plugin defines the commands:

- `TestNearest` - run the test nearest to the cursor
- `TestFile` - run all tests in the current file
- `TestSuite` - run the whole test suite
- `TestLast` - run the last test
- `TestVisit` - open the last run test in the current buffer
- `TestInfo` - show an information about the plugin

## Setup

This plugin must be explicitly enabled by using `require("nvim-test").setup{}`

Default options:

```lua
require('nvim-test').setup {
  commands_create = true,   -- create commands (TestFile, TestLast, ...)
  silent = false,           -- less notifications
  run = true,               -- run test commands
  term = "terminal",        -- a terminal to run (terminal|toggleterm)
  termOpts = {
    direction = "vertical", -- terminal's direction (horizontal|vertical|float)
    width = 96,             -- terminal's width (for vertical|float)
    height = 24,            -- terminal's height (for horizontal|float)
    go_back = false,        -- return focus to original window after executing
    stopinsert = false,     -- exit from insert mode
    keep_one = true,        -- only for term 'terminal', use only one buffer for testing
  },
  runners = {               -- setup tests runners
    go = "nvim-test.runners.go-test",
    javascript = "nvim-test.runners.jest",
    lua = "nvim-test.runners.busted",
    python = "nvim-test.runners.pytest",
    rust = "nvim-test.runners.cargo-test",
    typescript = "nvim-test.runners.jest",
  }
}
```

Setup a runner:
```lua
  require('nvim-test.runners.jest').setup {
    command = "~/node_modules/.bin/jest",
    args = " --collectCoverage=false ",
  }
```
