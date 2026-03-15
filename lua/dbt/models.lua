local scan = require('plenary.scandir')

--- @class Models
local models = {}

--- Scans models directory and returns files
--- @return string[]
models.model_files = function()
  return scan.scan_dir('models', { silent = true })
end

--- Returns path of a file if found in the models directory
--- @param self Models
--- @param name string
--- @param extension string | nil
--- @return string | nil
models.find_file_path = function(self, name, extension)
  if not extension then
    extension = ''
  end
  for _, path in pairs(self.model_files()) do
    if path:find('/' .. name .. extension) then
      return path
    end
  end
end

--- Returns path of a model if found, else nil.
--- @param self Models
--- @param name string
--- @return string | nil
models.find_model_path = function(self, name)
  return self:find_file_path(name, '.sql')
end

--- Returns path of a yaml config file if found, else nil.
--- @param self Models
--- @param name string
--- @return string | nil
models.find_yaml_path = function(self, name)
  vim.print(('Looking for yaml %s'):format(name))
  return self:find_file_path(name, '.yml')
end
return models
