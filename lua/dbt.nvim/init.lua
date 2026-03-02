local M

local scan = require('plenary.scandir')

--- @type string[]
local lines = {
  'select *',
  "from {{ ref('my_first_dbt_model') }}",
  'where id = 1',
}

local models = {}

--- @type string[]
models.models = scan.scan_dir('models', { search_pattern = '.*.sql' })
models.find_model_path = function(self, name)
  for _, path in pairs(self.models) do
    -- vim.print(('is %s in %s? %s'):format(name, path, path:find(name)))
    if path:find(name) then
      return path
    end
  end
end

for i = 1, #lines do
  local line = lines[i]
  -- vim.print(('doing %s').format(line))
  local match = line:match('{{%s*ref%(%p(.*)%p%)%s}}')
  if match then
    -- vim.print(('found match %s'):format(match))
    local model_path = models:find_model_path(match)
    -- vim.print(model_path)
    vim.api.nvim_command(('edit %s'):format(model_path))
  end
end

return M
