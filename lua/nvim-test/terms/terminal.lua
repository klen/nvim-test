local notifier = require "nvim-test.notify"
local directionsMap = {
  vertical = "vsplit",
  horizontal = "split",
}
local buffers = {}
local next = next

local exec = function(cmd, env, cfg)
  local opts = {
    on_exit = function(_, status)
      if cfg.stopinsert == "auto" and status ~= 0 then
        vim.cmd "stopinsert!"
        notifier:onotify("Tests are failed", 3)
      end
    end,
  }
  if env and next(env) then
    opts.env = env
  end
  return vim.fn.termopen(cmd, opts)
end

return function(cmd, env, cfg)
  if cfg.direction == "float" then
    local bufnr = vim.api.nvim_create_buf(false, false)
    vim.api.nvim_open_win(bufnr, true, {
      row = math.ceil(vim.o.lines - cfg.height) / 2 - 1,
      col = math.ceil(vim.o.columns - cfg.width) / 2 - 1,
      relative = "editor",
      width = cfg.width,
      height = cfg.height,
      style = "minimal",
      border = "single",
    })
    return exec(cmd, env, cfg)
  end

  local split = directionsMap[cfg.direction]
  if cfg.direction == "vertical" and cfg.width then
    split = cfg.width .. split
  end
  if cfg.direction == "horizontal" and cfg.height then
    split = cfg.height .. split
  end

  -- Clean buffers
  if cfg.keep_one then
    for pos, bufnr in ipairs(buffers) do
      if vim.fn.bufexists(bufnr) > 0 then
        vim.api.nvim_buf_delete(bufnr, { force = true })
        table.remove(buffers, pos)
      end
    end
  end

  vim.cmd(string.format("botright %s new", split))
  exec(cmd, env, cfg)

  table.insert(buffers, vim.api.nvim_get_current_buf())
  if cfg.stopinsert == true or cfg.go_back then
    vim.cmd "stopinsert!"
  end
  if cfg.go_back then
    vim.cmd "wincmd p"
  end
end
