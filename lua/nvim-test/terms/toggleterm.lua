local callbacks = require "nvim-test.terms.callbacks"

local terminal = require "toggleterm.terminal"
-- local ok, terminal = pcall(require, "toggleterm.terminal")
-- if not ok then
--   error "Install toggleterm.nvim to use toggleterm"
-- end

local term = nil

---Run terminal
---@param cmd table
---@param cfg table
---@param termCfg table
return function(cmd, cfg, termCfg)
  local command = cmd[1]
  for i = 2, #cmd do
    command = command .. " " .. vim.fn.shellescape(cmd[i])
  end
  local on_exit = callbacks.bind_on_exit(termCfg)

  -- Clean terminals
  if termCfg.keep_one and term then
    term:close()
  end

  term = terminal.Terminal:new {
    cmd = command,
    dir = cfg.working_directory,
    direction = termCfg.direction,
    close_on_exit = false,
    on_exit = function(_, _, status)
      on_exit(_, status)
    end,
  }
  term:open(
    termCfg.direction == "vertical" and termCfg.width or termCfg.height,
    termCfg.direction,
    true
  )
end
