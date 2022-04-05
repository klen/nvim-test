local notifier = require "nvim-test.notify"

local directionsMap = {
  vertical = "vsplit",
  horizontal = "split",
}
local buffers = {}
local next = next

local exec = function(cmd, cfg, termCfg)
  local opts = {
    on_exit = function(_, status)
      if termCfg.stopinsert == "auto" and status ~= 0 then
        vim.cmd "stopinsert!"
        notifier:onotify("Tests are failed", 3)
      end
    end,
  }
  if cfg.env and next(cfg.env) then
    opts.env = cfg.env
  end
  if cfg.working_directory and #cfg.working_directory > 0 then
    opts.cwd = cfg.working_directory
  end
  return vim.fn.termopen(cmd, opts)
end

return function(cmd, cfg, termCfg)
  if termCfg.direction == "float" then
    local bufnr = vim.api.nvim_create_buf(false, false)
    vim.api.nvim_open_win(bufnr, true, {
      row = math.ceil(vim.o.lines - termCfg.height) / 2 - 1,
      col = math.ceil(vim.o.columns - termCfg.width) / 2 - 1,
      relative = "editor",
      width = termCfg.width,
      height = termCfg.height,
      style = "minimal",
      border = "single",
    })
    return exec(cmd, cfg, termCfg)
  end

  local split = directionsMap[termCfg.direction]
  if termCfg.direction == "vertical" and termCfg.width then
    split = termCfg.width .. split
  end
  if termCfg.direction == "horizontal" and termCfg.height then
    split = termCfg.height .. split
  end

  -- Clean buffers
  if termCfg.keep_one then
    for pos, bufnr in ipairs(buffers) do
      if vim.fn.bufexists(bufnr) > 0 then
        vim.api.nvim_buf_delete(bufnr, { force = true })
        table.remove(buffers, pos)
      end
    end
  end

  vim.cmd(string.format("botright %s new", split))
  exec(cmd, cfg, termCfg)

  table.insert(buffers, vim.api.nvim_get_current_buf())
  if termCfg.stopinsert == true or termCfg.go_back then
    vim.cmd "stopinsert!"
  end
  if termCfg.go_back then
    vim.cmd "wincmd p"
  end
end
