local directions = {
  vertical = "vsplit",
  horizontal = "split",
}
local defaults = {
  size = 50, --- size number
  direction = "vertical", --- direction string
  go_back = true, --- go_back boolean whether or not to return to original window
}
return function(cmd, cfg)
  cfg = vim.tbl_deep_extend("force", defaults, cfg)
  local split = directions[cfg.direction]
  if cfg.size then
    split = cfg.size .. split
  end
  vim.cmd("botright " .. split .. " | term " .. cmd)
  if cfg.go_back then
    vim.cmd "wincmd p"
    vim.cmd "stopinsert!"
  end
end
