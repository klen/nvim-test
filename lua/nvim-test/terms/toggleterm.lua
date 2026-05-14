local callbacks = require "nvim-test.terms.callbacks"
local utils = require "nvim-test.utils"

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

  local width, height = utils.resolve_dimensions(termCfg)

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
    termCfg.direction == "vertical" and width or height,
    termCfg.direction,
    true
  )
end
