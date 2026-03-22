-- TODO: Got to think about how to organize this in the most sensible way
-- possible. Now it is just a collection of functions that handle buffers
-- and windows

local display = {}

display._instance = nil

--- @class Display
--- @field _results_window integer | nil
--- @field _terminal_window integer | nil
--- @field _terminal_channel integer | nil
--- @field _scratch_buffer integer | nil
--- @field _buffers table<string, bufferSpec>
local Display = {}
Display.__index = Display

-- Singleton
Display.new = function()
  if not display._instance then
    local self = setmetatable({}, Display)

    display._instance = self
    self._buffers = {
      show = { name = 'dbt show results', filetype = 'markdown' },
      terminal = { name = 'dbt executions', filetype = 'markdown' },
    }
  end

  return display._instance
end

Display.get_buffer = function(self, buffer_id)
  local buffer = self._buffers[buffer_id]

  if not buffer.bufnr then
    -- Create buffer
    buffer.bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(buffer.bufnr, buffer.name)
    vim.bo[buffer.bufnr].filetype = buffer.filetype

    -- Keymap to exit and avoid user modifying it
    vim.api.nvim_buf_set_keymap(
      buffer.bufnr,
      'n',
      'q',
      ':q<CR>',
      { desc = 'dbt - Close results window' }
    )
    vim.bo[buffer.bufnr].modifiable = false

    self._buffers[buffer_id] = buffer
  end

  return buffer
end

Display.get_scratch_buffer = function(self)
  if not self._scratch_buffer then
    self._scratch_buffer = vim.api.nvim_create_buf(false, true)
  end
  return self._scratch_buffer
end

Display.results_window = function(self)
  local windows = vim.api.nvim_list_wins()

  if not (self._results_window and vim.list_contains(windows, self._results_window)) then
    -- Create and open window below current window
    self._results_window = vim.api.nvim_open_win(
      self:get_buffer('show').bufnr,
      false,
      { split = 'below', height = math.floor(vim.o.lines * 0.3) }
    )
  end
  return self._results_window or error('Error obtaining results window')
end

---@param self Display
---@return bufferSpec terminal_buffer
Display.terminal_window = function(self)
  local windows = vim.api.nvim_list_wins()
  local buffer = self:get_buffer('terminal')

  if not (buffer.win and vim.list_contains(windows, self._terminal_window)) then
    -- Create and open window below current window
    buffer.win = vim.api.nvim_open_win(
      buffer.bufnr,
      false,
      { split = 'below', height = math.floor(vim.o.lines * 0.3) }
    )
  end
  if not buffer.chan then
    buffer.chan = vim.api.nvim_open_term(buffer.bufnr, {})
  end
  return buffer
end

Display.open_results_window = function(self, lines, filetype)
  local bufnr = self:get_buffer('show').bufnr

  vim.bo[bufnr].modifiable = true

  if filetype then
    vim.bo[bufnr].filetype = filetype
  end

  if lines then
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  end
  vim.bo[bufnr].modifiable = false

  return self:results_window()
end

Display.open_terminal_window = function(self, lines, filetype)
  local bufnr = self:get_buffer('terminal').bufnr

  vim.bo[bufnr].modifiable = true

  if filetype then
    vim.bo[bufnr].filetype = filetype
  end

  if lines then
    local last_line = vim.api.nvim_buf_line_count(bufnr)
    vim.api.nvim_buf_set_lines(bufnr, last_line, last_line, false, lines)
  end
  vim.bo[bufnr].modifiable = false

  return self:terminal_window()
end

Display.write_to_results = function(self, lines, filetype)
  self:open_results_window(lines, filetype)
end

Display.open_buffer_in_current_window = function(self, buffer, lines, filetype, path)
  local listed = false
  local scratch = true
  if path then
    listed = not listed
    scratch = not scratch
  end

  if path then
    buffer = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_buf_set_name(buffer, path)
  end

  if not buffer or buffer == 0 then
    buffer = self:get_scratch_buffer()
  end

  if lines then
    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, lines)
  end

  if filetype then
    vim.bo[buffer].filetype = filetype
  end

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

Display.write_to_terminal = function(self, _, data)
  self:open_terminal_window({ data })
end

return Display
