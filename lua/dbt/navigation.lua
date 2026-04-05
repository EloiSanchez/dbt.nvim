local models = require('dbt.dbt_project.models')

--- @class Navigation
local M = {}

--- Open buffer of first reference found in line
M.go_to_definition = function()
  local line = vim.api.nvim_get_current_line()
  local match = line:match('{{%s*ref%(%p(.*)%p%)%s}}')

  -- If match is found in line, find path and jump to it
  if match then
    local model_path = models:find_model_path(match)
    if model_path then
      vim.api.nvim_command(('edit %s'):format(model_path))
      return
    end
  end
  vim.notify('No model reference found.')
end

M.go_to_references = function(buffer)
  -- If buffer not passed or not number, use current buffer
  if type(buffer) ~= 'number' then
    buffer = 0
  end
  local path = vim.api.nvim_buf_get_name(buffer)

  -- Find references of model
  local items = models.find_references(path)

  -- If no references found then exit
  if not (#items > 0) then
    vim.notify('No references found for current model', vim.log.levels.INFO)
    return
  end

  -- Create dict to send to setloclist and open it
  local list = {
    items = models.find_references(path),
  }
  vim.fn.setloclist(0, {}, ' ', list)
  vim.cmd.lopen()
end

return M
