local ok, toggleterm = pcall(require, "toggleterm")

if not ok then
  error "Install toggleterm.nvim to use toggleterm"
end

local defaults = {
  num = 0, --- num number
  size = 50, --- size number
  dir = "", --- dir string
  direction = "vertical", --- direction string
  go_back = true, --- go_back boolean whether or not to return to original window
  open = true, --- open boolean whether or not to open terminal window
}

return function(cmd, cfg)
  cfg = vim.tbl_deep_extend("force", defaults, cfg)
  return toggleterm.exec(cmd, cfg.num, cfg.size, cfg.dir, cfg.direction, cfg.go_back, cfg.open)
end
