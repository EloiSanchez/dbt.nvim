local display = {}

display._instance = nil

--- @class Display
--- @field _results_buffer integer | nil
--- @field _results_window integer | nil
local Display = {}
Display.__index = Display

-- Singleton
Display.new = function()
  if not display._instance then
    local self = setmetatable({}, Display)

    display._instance = self
  end

  return display._instance
end

Display.results_buffer = function(self, filetype)
  if not self._results_buffer then
    -- Create buffer
    self._results_buffer = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(self._results_buffer, 'dbt show results')
    vim.bo[self._results_buffer].filetype = filetype or 'markdown'

    -- Keymap to exit and avoid user modifying it
    vim.api.nvim_buf_set_keymap(
      self._results_buffer,
      'n',
      'q',
      ':q<CR>',
      { desc = 'dbt - Close results window' }
    )
    vim.bo[self._results_buffer].modifiable = false
  end

  return self._results_buffer or error('Results buffer not set')
end

Display.results_window = function(self)
  local windows = vim.api.nvim_list_wins()

  if not (self._results_window and vim.list_contains(windows, self._results_window)) then
    -- Create and open window below current window
    self._results_window = vim.api.nvim_open_win(
      self:results_buffer(),
      false,
      { split = 'below', height = math.floor(vim.o.lines * 0.3) }
    )
  end
  return self._results_window or error('Error obtaining results window')
end

Display.open_results_window = function(self, lines, filetype)
  local results_buffer = self:results_buffer()

  vim.bo[results_buffer].modifiable = true

  if filetype then
    vim.bo[results_buffer].filetype = filetype
  end

  if lines then
    vim.api.nvim_buf_set_lines(results_buffer, 0, -1, false, lines)
  end
  vim.bo[results_buffer].modifiable = false

  return self:results_window()
end

Display.write_to_results = function(self, lines, filetype)
  self:open_results_window(lines, filetype)
end

Display.open_buffer_in_current_window = function(buffer, lines, filetype)
  if not buffer or buffer == 0 then
    buffer = vim.api.nvim_create_buf(false, true)
  end

  if lines then
    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, lines)
  end

  if filetype then
    vim.bo[buffer].filetype = filetype
  end

  -- Floating
  -- local width = math.floor(vim.o.columns * 0.6)
  -- local height = math.floor(vim.o.lines * 0.9)
  -- local row = (vim.o.columns - width) - 1
  -- local col = (vim.o.columns - height) - 1
  -- -- local win = vim.wo[vim.api.nvim_get_current_win()]
  -- vim.print({ width = width, height = height, row = row, col = col })
  -- vim.api.nvim_open_win(buffer, true, {
  --   relative = 'win',
  --   row = 2,
  --   col = 3,
  --   width = 5,
  --   height = 7,
  --   anchor = 'NW',
  --   border = { '╔', '═', '╗', '║', '╝', '═', '╚', '║' },
  -- })

  -- Not floating
  vim.api.nvim_win_set_buf(0, buffer)
  return buffer
end

Display.write_out_to_buffer = function(buffer, stdout, stderr, filetype)
  vim.api.nvim_buf_set_lines(
    buffer,
    0,
    -1,
    false,
    vim.list_extend(vim.split(stdout, '\n'), vim.split(stderr, '\n'))
  )

  if filetype then
    vim.bo[buffer].filetype = filetype
  end
end

return Display
