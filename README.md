<img src="https://neovim.io/logos/neovim-mark-flat.png" align="right" width="144" />

# nvim-test 1.3.0

Test Runner for neovim

[![tests](https://github.com/klen/nvim-test/actions/workflows/tests.yml/badge.svg)](https://github.com/klen/nvim-test/actions/workflows/tests.yml)
[![Awesome Neovim](https://awesome.re/badge-flat.svg)](https://github.com/rockerBOO/awesome-neovim)


## Features

| Language       | Test Runners                     |
| -------------: | :------------------------------- |
| **C Sharp**    | `dotnet test`                    |
| **Go**         | `go-test`                        |
| **Haskell**    | `hspec`, `stack`                 |
| **Javascript** | `jest`, `mocha`                  |
| **Lua**        | `busted`, `vusted`               |
| **Python**     | `pytest`, `pyunit`               |
| **Ruby**       | `rspec`                          |
| **Rust**       | `cargo-test`                     |
| **Typescript** | `jest`, `mocha`, `ts-mocha`      |

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

- `TestSuite` - run the whole test suite
- `TestFile` - run all tests for the current file
- `TestEdit` - edit tests for the current file
- `TestNearest` - run the test nearest to the cursor
- `TestLast` - rerun the latest test
- `TestVisit` - open the last run test in the current buffer
- `TestInfo` - show an information about the plugin

## Setup

This plugin must be explicitly enabled by using `require("nvim-test").setup{}`

Default options:

```lua
require('nvim-test').setup {
  run = true,                 -- run tests (using for debug)
  commands_create = true,     -- create commands (TestFile, TestLast, ...)
  filename_modifier = ":.",   -- modify filenames before tests run(:h filename-modifiers)
  silent = false,             -- less notifications
  term = "terminal",          -- a terminal to run ("terminal"|"toggleterm")
  termOpts = {
    direction = "vertical",   -- terminal's direction ("horizontal"|"vertical"|"float")
    width = 96,               -- terminal's width (for vertical|float)
    height = 24,              -- terminal's height (for horizontal|float)
    go_back = false,          -- return focus to original window after executing
    stopinsert = "auto",      -- exit from insert mode (true|false|"auto")
    keep_one = true,          -- keep only one terminal for testing
  },
  runners = {               -- setup tests runners
    cs = "nvim-test.runners.dotnet",
    go = "nvim-test.runners.go-test",
    haskell = "nvim-test.runners.hspec",
    javascriptreact = "nvim-test.runners.jest",
    javascript = "nvim-test.runners.jest",
    lua = "nvim-test.runners.busted",
    python = "nvim-test.runners.pytest",
    ruby = "nvim-test.runners.rspec",
    rust = "nvim-test.runners.cargo-test",
    typescript = "nvim-test.runners.jest",
    typescriptreact = "nvim-test.runners.jest",
  }
}
```

Setup a runner:
```lua
  require('nvim-test.runners.jest'):setup {
    command = "~/node_modules/.bin/jest",                                       -- a command to run the test runner
    args = { "--collectCoverage=false" },                                       -- default arguments
    env = { CUSTOM_VAR = 'value' },                                             -- custom environment variables

    file_pattern = "\\v(__tests__/.*|(spec|test))\\.(js|jsx|coffee|ts|tsx)$",   -- determine whether a file is a testfile
    find_files = { "{name}.test.{ext}", "{name}.spec.{ext}" },                  -- find testfile for a file

    filename_modifier = nil,                                                    -- modify filename before tests run (:h filename-modifiers)
    working_directory = nil,                                                    -- set working directory (cwd by default)
  }
```
