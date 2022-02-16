local ok, toggleterm = pcall(require, "toggleterm")

if not ok then
  error "Install toggleterm.nvim to use toggleterm"
end

local defaults = {
  num = 0, --- num number
  dir = "", --- dir string
  open = true, --- open boolean whether or not to open terminal window
}

return function(cmd, cfg)
  cfg = vim.tbl_deep_extend("force", defaults, cfg)
  local size = cfg.direction == "vertical" and cfg.width or cfg.height
  toggleterm.exec(cmd, cfg.num, cfg.size or size, cfg.dir, cfg.direction, cfg.go_back, cfg.open)
  if cfg.stopinsert then
    vim.cmd "normal! G"
    vim.cmd "stopinsert!"
  end
end
