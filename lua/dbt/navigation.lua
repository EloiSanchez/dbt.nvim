local models = require('dbt.models')

--- @class Navigation
local M = {}

--- Open buffer of first reference found in line
M.go_to_definition = function()
  local line = vim.api.nvim_get_current_line()
  local match = line:match('{{%s*ref%(%p(.*)%p%)%s}}')

  -- If match is found in line, find path and jump to it
  if match then
    local model_path = models:find_model_path(match)
    vim.api.nvim_command(('edit %s'):format(model_path))
  else
    vim.notify('No model reference found.')
  end
end

return M
