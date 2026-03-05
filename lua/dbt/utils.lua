local utils = {}

-- TODO: This needs to be moved somewhere so its loaded once when plugin is loaded lazily
-- and available in the whole module without requiring re-execution

local dbt_version_command = vim.system({ 'pip', 'freeze' }, { text = true })
local dbt_executable_command = vim.system({ 'which', 'dbt' }, { text = true })

-- Find if dbt executable in path
local out = dbt_executable_command:wait()

if out.stderr ~= '' then
  vim.notify('No dbt executable found. Defaulting to dbt.', vim.log.levels.WARN)
  utils.dbt = 'dbt'
else
  utils.dbt = out.stdout
end

-- Find dbt version
out = dbt_version_command:wait()
if out.stderr ~= '' and utils.dbt then
  vim.notify('Could not find dbt core version. Defaulting to 1.11.7.', vim.log.levels.WARN)
  utils.dbt_version = '1.11.7'
else
  local lines = vim.split(out.stdout, '\n')
  for _, line in ipairs(lines) do
    local match = string.match(line, 'dbt%-core==(.*)')
    if match then
      utils.dbt_version = match
      break
    end
  end
end

return utils
