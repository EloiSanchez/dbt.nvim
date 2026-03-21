-- TODO: Got to think about how to organize this in the most sensible way
-- possible. Now it is just a collection of functions that handle buffers
-- and windows

local display = {}

display._instance = nil

--- @class Display
--- @field buffer integer | nil
--- @field _results_window integer | nil
--- @field _terminal_window integer | nil
--- @field _terminal_channel integer | nil
--- @field _scratch_buffer integer | nil
--- @field _buffers table<string, integer>
local Display = {}
Display.__index = Display

-- Singleton
Display.new = function()
  if not display._instance then
    local self = setmetatable({}, Display)

    display._instance = self
    self._buffers = {}
  end

  return display._instance
end

Display.get_buffer = function(self, buffer_id, filetype)
  local buffer = self._buffers[buffer_id]

  if not buffer then
    -- Create buffer
    buffer = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(buffer, ('dbt %s'):format(buffer_id))
    vim.bo[buffer].filetype = filetype or 'markdown'

    -- Keymap to exit and avoid user modifying it
    vim.api.nvim_buf_set_keymap(buffer, 'n', 'q', ':q<CR>', { desc = 'dbt - Close results window' })
    vim.bo[buffer].modifiable = false

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
      self:get_buffer('show results'),
      false,
      { split = 'below', height = math.floor(vim.o.lines * 0.3) }
    )
  end
  return self._results_window or error('Error obtaining results window')
end

---@param self Display
---@return integer terminal_window
---@return integer terminal_buffer
---@return integer terminal_channel
Display.terminal_window = function(self)
  local windows = vim.api.nvim_list_wins()
  local buffer = self:get_buffer('terminal')

  if not (self._terminal_window and vim.list_contains(windows, self._terminal_window)) then
    -- Create and open window below current window
    self._terminal_window = vim.api.nvim_open_win(
      self:get_buffer('terminal'),
      false,
      { split = 'below', height = math.floor(vim.o.lines * 0.3) }
    )
  end
  if not self._terminal_channel then
    self._terminal_channel = vim.api.nvim_open_term(buffer, {})
  end
  return self._terminal_window, buffer, self._terminal_channel
end

Display.open_results_window = function(self, lines, filetype)
  local results_buffer = self:get_buffer('show results')

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

Display.open_terminal_window = function(self, lines, filetype)
  local terminal_buffer = self:get_buffer('terminal')

  vim.bo[terminal_buffer].modifiable = true

  if filetype then
    vim.bo[terminal_buffer].filetype = filetype
  end

  if lines then
    local last_line = vim.api.nvim_buf_line_count(terminal_buffer)
    vim.api.nvim_buf_set_lines(terminal_buffer, last_line, last_line, false, lines)
  end
  vim.bo[terminal_buffer].modifiable = false

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

Display.write_to_terminal = function(self, err, data)
  -- vim.print(err)
  -- vim.print(data)
  self:open_terminal_window({ data })
end

return Display
