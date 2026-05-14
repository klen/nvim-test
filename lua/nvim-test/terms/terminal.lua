local callbacks = require "nvim-test.terms.callbacks"
local utils = require "nvim-test.utils"

local directionsMap = {
  vertical = "vsplit",
  horizontal = "split",
}
local term = nil
local next = next

local exec = function(cmd, cfg, termCfg)
  local opts = {
    on_exit = callbacks.bind_on_exit(termCfg),
  }
  if cfg.env and next(cfg.env) then
    opts.env = cfg.env
  end
  if cfg.working_directory and #cfg.working_directory > 0 then
    opts.cwd = cfg.working_directory
  end
  return vim.fn.jobstart(cmd, vim.tbl_extend("keep", opts, { term = true }))
end

return function(cmd, cfg, termCfg)
  local width, height = utils.resolve_dimensions(termCfg)

  if termCfg.direction == "float" then
    local bufnr = vim.api.nvim_create_buf(false, false)
    vim.api.nvim_open_win(bufnr, true, {
      row = math.ceil(vim.o.lines - height) / 2 - 1,
      col = math.ceil(vim.o.columns - width) / 2 - 1,
      relative = "editor",
      width = width,
      height = height,
      style = "minimal",
      border = "single",
    })
    return exec(cmd, cfg, termCfg)
  end

  local split = directionsMap[termCfg.direction]
  if termCfg.direction == "vertical" and width then
    split = width .. split
  end
  if termCfg.direction == "horizontal" and height then
    split = height .. split
  end

  -- Clean buffers
  if termCfg.keep_one and term then
    if vim.fn.bufexists(term) > 0 then
      vim.api.nvim_buf_delete(term, { force = true })
    end
  end

  vim.cmd(string.format("botright %s new", split))
  exec(cmd, cfg, termCfg)
  term = vim.api.nvim_get_current_buf()
end
