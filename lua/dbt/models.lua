local scan = require('plenary.scandir')

--- @class Models
local models = {}

--- @type string[]
models.models = scan.scan_dir('models', { search_pattern = '.*.sql' })

--- Returns path of a model if found, else nil.
--- @param self Models
--- @param name string
--- @return string | nil
models.find_model_path = function(self, name)
  for _, path in pairs(self.models) do
    if path:find(name) then
      return path
    end
  end
end

return models
