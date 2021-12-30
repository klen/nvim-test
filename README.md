# nvim-test

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
