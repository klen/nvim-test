local notifier = require "nvim-test.notify"

local M = {}

---Bind on_exit callback
---@param cfg table
---@return function
function M.bind_on_exit(cfg)
  return function(_, status)
    local stopinsert = cfg.stopinsert
    if status ~= 0 then
      notifier:onotify("Tests are failed", 3)
      if stopinsert == "auto" then
        stopinsert = true
      end
    end
    if stopinsert == true or cfg.go_back then
      vim.cmd "stopinsert!"
    end
    if cfg.go_back then
      vim.cmd "wincmd p"
    end
  end
end

return M
