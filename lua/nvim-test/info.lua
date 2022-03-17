function open_window()
  local width = math.floor(vim.o.columns * 0.7)
  local height = math.floor(vim.o.lines * 0.7)
  local bufnr = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(bufnr, true, {
    width = width,
    height = height,
    row = math.floor(((vim.o.lines - height) / 2) - 1),
    col = math.floor((vim.o.columns - width) / 2),
    relative = "editor",
    style = "minimal",
    border = {
      { " ", "NormalFloat" },
      { " ", "NormalFloat" },
      { " ", "NormalFloat" },
      { " ", "NormalFloat" },
      { " ", "NormalFloat" },
      { " ", "NormalFloat" },
      { " ", "NormalFloat" },
      { " ", "NormalFloat" },
    },
  })
  vim.api.nvim_win_set_buf(win, bufnr)
  vim.cmd "setlocal nocursorcolumn ts=2 sw=2"
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<esc>", "<cmd>bd<CR>", { noremap = true })
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<C-C>", "<cmd>bd<CR>", { noremap = true })
  vim.api.nvim_command(
    string.format(
      "autocmd BufHidden,BufLeave <buffer> ++once lua pcall(vim.api.nvim_win_close, %d, true)",
      win
    )
  )
  return { win = win, bufnr = bufnr }
end

function print_table(t, indent)
  local result = {}
  indent = indent == nil and "" or indent
  for key, value in pairs(t) do
    if type(value) == "table" then
      table.insert(result, indent .. key .. ": ")
      vim.list_extend(result, print_table(value, indent .. "\t"))
    else
      table.insert(result, indent .. key .. ": " .. vim.inspect(value))
    end
  end
  return result
end

return function()
  local plugin = require "nvim-test"
  local filetype = vim.bo.filetype
  local window = open_window()

  local lines = { "=============", "PLUGIN CONFIG", ">" }
  vim.list_extend(lines, print_table(plugin.config, "\t"))
  table.insert(lines, "")

  if filetype then
    vim.list_extend(lines, { "-------------------", "Detected filetype: *" .. filetype .. "*" })
    local runner_module = plugin.config.runners[filetype]
    if runner_module then
      table.insert(lines, "Found test runner: *" .. runner_module .. "*")
      local _, runner = pcall(require, runner_module)
      if runner then
        vim.list_extend(lines, { "", "Runner Config: >" })
        vim.list_extend(lines, print_table(runner.config, "\t"))
      end
    else
      table.insert(lines, "Test runner not found")
    end
  end

  if vim.g.nvim_last then
    vim.list_extend(lines, { "", "-------------------", "Last test: `" .. vim.g.nvim_last .. "`" })
  end

  vim.api.nvim_buf_set_lines(window.bufnr, 0, -1, true, lines)
  vim.api.nvim_buf_set_option(window.bufnr, "modifiable", false)
  vim.api.nvim_buf_set_option(window.bufnr, "filetype", "help")
end
