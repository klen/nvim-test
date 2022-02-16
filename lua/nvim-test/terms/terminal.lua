local directionsMap = {
  vertical = "vsplit",
  horizontal = "split",
}

return function(cmd, cfg)
  if cfg.direction == "float" then
    local bufnr = vim.api.nvim_create_buf(false, false)
    vim.api.nvim_open_win(bufnr, true, {
      row = math.ceil(vim.o.lines - cfg.size) / 2 - 1,
      col = math.ceil(vim.o.columns - cfg.size) / 2 - 1,
      relative = "editor",
      width = cfg.size,
      height = cfg.size,
      style = "minimal",
      border = "single",
    })
    return vim.cmd("term " .. cmd)
  end
  local split = directionsMap[cfg.direction]
  if cfg.direction == "vertical" and cfg.width then
    split = cfg.width .. split
  end
  if cfg.direction == "horizontal" and cfg.height then
    split = cfg.height .. split
  end
  vim.cmd("botright " .. split .. " | term " .. cmd)
  if cfg.stopinsert or cfg.go_back then
    vim.cmd "stopinsert!"
    vim.cmd "normal! G"
  end
  if cfg.go_back then
    vim.cmd "wincmd p"
  end
end
