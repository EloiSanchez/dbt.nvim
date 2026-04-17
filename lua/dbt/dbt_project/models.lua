-- TODO: Add functions to find everything (source, models, yamls, macros...). Maybe a class
-- is not needed, and it would be best to have a collection of functions that get whatever is
-- needed from the project directory

--- @class Models
local models = {}

--- Scans models directory and returns files
--- @return string[]
models.model_files = function(opts)
  local extended_opts = vim.tbl_extend('force', { silent = true }, opts or {})

  -- TODO: Allow parsing projects as defined in dbt_project.yaml, not only
  -- from the hard coded `./models/` directory
  local scan = require('plenary.scandir')
  return scan.scan_dir('models', extended_opts)
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

--- Returns base name of sql path
--- @param path string
--- @return string
models.extract_base_name = function(path)
  local buf_path = require('plenary.path'):new(path)
  local buf_splitted = buf_path:_split(buf_path._sep)
  return string.match(buf_splitted[#buf_splitted], '(.*)%psql')
end

--- Returns quickfix entries for references of model in `path`
--- @param path string
--- @return vim.quickfix.entry[]
models.find_references = function(path)
  --- @type vim.quickfix.entry[]
  local entries = {}
  local name_to_match = models.extract_base_name(path)

  -- Iterate over sql files found in models/
  for _, filename in ipairs(models.model_files({ search_pattern = '.*%.sql' })) do
    for line_number, line in ipairs(require('plenary.path'):new(filename):readlines()) do
      local match = string.match(line, '.*{{.*ref.*%(.*[\'"]' .. name_to_match .. '[\'"].*%).*}}.*')
      if match then
        table.insert(entries, {
          filename = filename,
          lnum = line_number,
          col = 0,
          text = models.extract_base_name(filename),
        })
      end
    end
  end

  return entries
end

models.completion = function(arg_lead)
  local base_names = {}
  for _, v in ipairs(models.model_files()) do
    if vim.startswith(v, arg_lead) then
      table.insert(base_names, models.extract_base_name(v))
    end
  end
  return base_names
end

return models
