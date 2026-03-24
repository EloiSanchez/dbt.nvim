-- TODO: Got to think about how to organize this in the most sensible way
-- possible. Now it is just a collection of functions that handle buffers
-- and windows

local display = {}

display._instance = nil

--- @class Display
--- @field _scratch_buffer integer | nil
--- @field _docked_window table<string, any>
--- @field _buffers table<string, bufferSpec>
local Display = {}
Display.__index = Display

-- Singleton
Display.get_instance = function()
  if not display._instance then
    local self = setmetatable({}, Display)

    display._instance = self
    self._buffers = {
      show = { name = 'dbt show results', filetype = 'markdown', is_terminal = false },
      terminal = { name = 'dbt executions', filetype = 'markdown', is_terminal = true },
    }
    self._docked_window = { buffer_id = nil, win = nil }
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

---@param self Display
---@param buffer_id string
---@return bufferSpec terminal_buffer
---@return table<string, any> docked_window
Display.get_window = function(self, buffer_id)
  local windows = vim.api.nvim_list_wins()
  local buffer = self:get_buffer(buffer_id)

  -- If window is not open
  if not (self._docked_window.win and vim.list_contains(windows, self._docked_window.win)) then
    -- Create and open window below current window
    self._docked_window.win = vim.api.nvim_open_win(
      buffer.bufnr,
      false,
      { split = 'below', height = math.floor(vim.o.lines * 0.3) }
    )
  end

  -- If buffer is terminal, attach channel
  if buffer.is_terminal and not buffer.chan then
    buffer.chan = vim.api.nvim_open_term(buffer.bufnr, {})
  end

  -- Ensure correct buffer is attached to window
  if self._docked_window.buffer_id ~= buffer_id then
    vim.api.nvim_win_set_buf(self._docked_window.win, buffer.bufnr)
    self._docked_window.buffer_id = buffer_id
  end

  return buffer, self._docked_window
end

Display.open_window = function(self, buffer_id, lines, filetype, is_append)
  local bufnr = self:get_buffer(buffer_id).bufnr

  vim.bo[bufnr].modifiable = true

  if filetype then
    vim.bo[bufnr].filetype = filetype
  end

  if lines then
    local start_line = 0
    local last_line = -1
    if is_append then
      last_line = vim.api.nvim_buf_line_count(bufnr)
      start_line = last_line
    end
    vim.api.nvim_buf_set_lines(bufnr, start_line, last_line, false, lines)
  end
  vim.bo[bufnr].modifiable = false

  return self:get_window(buffer_id)
end

Display.write_to_buffer = function(self, buffer_id, lines, filetype)
  self:open_window(buffer_id, lines, filetype)
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

return Display
