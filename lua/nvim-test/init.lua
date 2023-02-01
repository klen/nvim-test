local notifier = require "nvim-test.notify"
local api = vim.api
local suite_runner
local Runner = require "nvim-test.runner"
local M = {
  config = vim.deepcopy(require "nvim-test.config"),
  runners = require "nvim-test.runners",
}

-- Run tests
---
---@param scope string: (suite|file|nearest|last)
function M.run(scope)
  -- Run latest
  if scope == "last" then
    return M.run_latest()
  end

  -- Check for is the filetype is supported
  local filetype = vim.bo.filetype
  local runner = M.get_runner(filetype, scope == "suite" and suite_runner or nil)
  if runner then
    suite_runner = runner
    local opts = {}
    local filename = nil

    -- Find tests
    if scope == "nearest" then
      opts.tests = runner:find_nearest_test(filetype)
    end

    -- Find file
    if scope ~= "suite" then
      filename =
        vim.fn.expand("%" .. (runner.config.filename_modifier or M.config.filename_modifier))
      if not runner:is_testfile(filename) then
        filename = runner:find_file(filename)
      end
    end

    -- Find the current working directory
    local cwd = runner:find_working_directory(filename)
    if filename and cwd and #cwd > 0 then
      filename = string.gsub(filename, "^" .. cwd .. "/", "", 1)
    end

    -- Prepare run context
    local cmd = runner:build_cmd(filename, opts)
    local cfg = { env = runner.config.env, working_directory = cwd }

    -- Save last run
    vim.g.test_latest = {
      cmd = cmd,
      cfg = cfg,
      filename = filename,
      line = api.nvim_win_get_cursor(0)[0],
    }

    return M.run_cmd(cmd, cfg)
  end
end

--- Repeat a latest test command
function M.run_last()
  local latest = vim.g.test_latest
  if not latest then
    return notifier:notify("No tests were run so far", 3)
  end
  return M.run_cmd(latest.cmd, latest.cfg)
end

---Get a runner by the given filetype
---@return Runner runner
function M.get_runner(filetype, default)
  local runner_module = M.runners[filetype]
  if runner_module then
    local _, runner = pcall(require, runner_module)
    if runner then
      return runner
    end
  end
  local runner = default
  if not runner then
    notifier:notify(string.format("Test runner for `%s` is not found", filetype), 4)
  end
  return runner
end

-- Visit the latest test
function M.visit()
  local opts = vim.g.test_latest
  if opts and opts.filename then
    local args = opts.line and string.format("+%s", opts.line) or ""
    return api.nvim_command(string.format("edit %s%s", opts.filename, args))
  end
  return notifier:notify("No tests were run so far", 3)
end

function M.edit()
  local runner = M.get_runner(vim.bo.filetype)
  local filename =
    vim.fn.expand("%" .. (runner.config.filename_modifier or M.config.filename_modifier))
  if not runner:is_testfile(filename) then
    vim.api.nvim_command("edit " .. runner:find_file(filename, true))
  end
end

--- Run the given command
---
---@param cmd table: a command to run
---@param cfg table: a runner's config
function M.run_cmd(cmd, cfg)
  notifier:log(table.concat(cmd, " "))
  if not M.config.run then
    return
  end
  local supported, termExec = pcall(require, "nvim-test.terms." .. M.config.term)
  if not supported then
    return notifier:notify(string.format("Term: %s is not supported", M.config.term), 4)
  end
  local opts = M.config.termOpts
  vim.validate {
    direction = { opts.direction, "string" },
    width = { opts.width, "number" },
    height = { opts.height, "number" },
    go_back = { opts.go_back, "boolean" },
    -- stopinsert = { opts.stopinsert, "boolean" },
  }
  return termExec(cmd, cfg, opts)
end

-- Setup the plugin
---
---@param cfg table: a table with configuration
function M.setup(cfg)
  -- Update config
  if cfg ~= nil then
    M.config = vim.tbl_deep_extend("force", M.config, cfg)
  end

  if M.config.runners then
    M.runners = vim.tbl_deep_extend("force", M.runners, M.config.runners)
  end

  -- Reset latest
  vim.g.test_latest = nil

  -- Setup notifies
  notifier:setup(M.config.silent)

  -- Create commands
  if M.config.commands_create then
    api.nvim_command "command! TestFile lua require'nvim-test'.run('file')<CR>"
    api.nvim_command "command! TestLast lua require'nvim-test'.run_last()<CR>"
    api.nvim_command "command! TestNearest lua require'nvim-test'.run('nearest')<CR>"
    api.nvim_command "command! TestSuite lua require'nvim-test'.run('suite')<CR>"
    api.nvim_command "command! TestVisit lua require'nvim-test'.visit()<CR>"
    api.nvim_command "command! TestInfo lua require'nvim-test.info'()<CR>"
    api.nvim_command "command! TestEdit lua require'nvim-test'.edit()<CR>"
  end
end

return M
