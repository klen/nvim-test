local Notifier = require "nvim-test.notify"
local api = vim.api
local M = {
  config = vim.deepcopy(require "nvim-test.config"),
  notifier = nil,
}

-- Run tests
---
---@param scope string: (suite|file|nearest|last)
function M.run(scope)
  -- Run latest
  if scope == "last" then
    if vim.g.nvim_last == nil then
      return M.notifier:notify("No tests were run so far", "ErrorMsg")
    end
    return M.run_cmd(vim.g.nvim_last)
  end

  -- Check for is the filetype is supported
  local filetype = vim.bo.filetype
  local runner_module = M.config.runners[filetype]
  local supported, runner = pcall(require, runner_module)
  if not supported then
    return M.notifier:notify(string.format("%s is not supported", filetype), "ErrorMsg")
  end

  local opts = {}
  local filename = nil
  if scope == "nearest" then
    opts.tests = runner:find_tests(filetype)
  end

  if scope ~= "suite" then
    filename = vim.fn.expand "%:p"
  end

  local cmd = runner:build_cmd(filename, opts)
  return M.run_cmd(cmd)
end

--- Run the given command
---
---@param cmd string: a command to run
function M.run_cmd(cmd)
  vim.g.nvim_last = cmd
  M.notifier:onotify(cmd)
  if M.config.run then
    if M.config.split then
      vim.cmd(M.config.split)
    end
    vim.cmd(M.config.cmd:format(cmd))
  end
end

-- Setup the plugin
---
---@param cfg table: a table with configuration
function M.setup(cfg)
  -- Update config
  if cfg ~= nil then
    M.config = vim.tbl_deep_extend("force", M.config, cfg)
  end

  -- Initialize tools
  M.notifier = Notifier:init(M.config.silent)

  -- Create commands
  if M.config.commands_create then
    api.nvim_command "command! TestFile lua require'nvim-test'.run('file')<CR>"
    api.nvim_command "command! TestLast lua require'nvim-test'.run('last')<CR>"
    api.nvim_command "command! TestNearest lua require'nvim-test'.run('nearest')<CR>"
    api.nvim_command "command! TestSuite lua require'nvim-test'.run('suite')<CR>"
  end
end

return M
