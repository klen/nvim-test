local ok, toggleterm = pcall(require, "toggleterm")

if not ok then
  error "Install toggleterm.nvim to use toggleterm"
end

local defaults = {
  num = 0, --- num number
  dir = "", --- dir string
  open = true, --- open boolean whether or not to open terminal window
}

return function(cmd, _, termCfg)
  termCfg = vim.tbl_deep_extend("force", defaults, termCfg)
  local size = termCfg.direction == "vertical" and termCfg.width or termCfg.height
  toggleterm.exec(
    cmd,
    termCfg.num,
    termCfg.size or size,
    termCfg.dir,
    termCfg.direction,
    termCfg.go_back,
    termCfg.open
  )
  if termCfg.stopinsert then
    vim.cmd "normal! G"
    vim.cmd "stopinsert!"
  end
end
