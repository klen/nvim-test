local Notifier = {}
Notifier.__index = Notifier

--Initialize hash helper
---@param silent boolean: is silent mode enabled
---@returns Notifier
function Notifier:init(silent)
  self = {}
  setmetatable(self, Notifier)
  self.silent = silent
  self.prefix = "[nvim-test]: "
  return self
end

--Send notify
function Notifier:notify(msg, hl)
  hl = hl or "ErrorMsg"
  vim.api.nvim_echo({ { self.prefix .. msg, hl } }, true, {})
end

--Send optional notify
function Notifier:onotify(msg, hl)
  if not self.silent then
    self:notify(msg, hl)
  end
end

--Ask for a confirmation
function Notifier:confirm(msg, choices)
  local _, choice = pcall(vim.fn.confirm, self.prefix .. msg, choices, 1)
  return choice
end

return Notifier
