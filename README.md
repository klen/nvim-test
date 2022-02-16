# nvim-test 0.0.3

Test Runner for neovim

[![tests](https://github.com/klen/nvim-test/actions/workflows/tests.yml/badge.svg)](https://github.com/klen/nvim-test/actions/workflows/tests.yml)

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
    direction = "horizontal", -- terminal's direction (horizontal|vertical) (for toggleterm float also supported)
    size = 20,                -- terminal's size
    go_back = false,           -- return focus to original window after executing
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
