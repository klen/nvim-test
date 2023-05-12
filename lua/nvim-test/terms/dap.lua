local dap = require "dap"

---Run terminal
---@param cmd table
---@param termCfg table
return function(cmd, _, termCfg)
  local command = cmd[1]
  local dapCfg = vim.tbl_extend("keep", {
    runtimeExecutable = command,
    runtimeArgs = { unpack(cmd, 2) },
  }, termCfg.dap)
  dap.run(dapCfg)
end
