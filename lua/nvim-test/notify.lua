local Notifier = {}
Notifier.__index = Notifier

--Initialize hash helper
---@returns Notifier
function Notifier:init()
  self = {}
  setmetatable(self, Notifier)
  self.silent = false
  self.prefix = "[nvim-test]: "
  return self
end

---@param silent boolean: is silent mode enabled
function Notifier:setup(silent)
  self.silent = silent
  return self
end

--Send notify
function Notifier:notify(msg, level)
  vim.notify(self.prefix .. msg, level or 2)
end

--Send optional notify
function Notifier:onotify(msg, level)
  if not self.silent then
    self:notify(msg, level)
  end
end

-- Log a message
function Notifier:log(msg)
  vim.api.nvim_echo({ { self.prefix .. msg } }, true, {})
end

--Ask for a confirmation
function Notifier:confirm(msg, choices)
  local _, choice = pcall(vim.fn.confirm, self.prefix .. msg, choices, 1)
  return choice
end

return Notifier:init()
