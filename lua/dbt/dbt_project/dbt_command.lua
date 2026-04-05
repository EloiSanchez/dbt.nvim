local Path = require('plenary.path')

--- @class dbtCommand
--- @field command string
--- @field args dbtArgs
local dbtCommand = {}
dbtCommand.__index = dbtCommand

--- Create new dbt command
--- @param command string
--- @param args dbtArgs
--- @return dbtCommand
dbtCommand.new = function(command, args)
  local self = setmetatable({}, dbtCommand)
  self.command = command
  self.args = args or {}
  if self.args.selector then
    self:add_selector(self.args.selector)
  end
  self.args.flags = self.args.flags or {}
  self.args.extra_args = self.args.extra_args or {}
  return self
end

--- Add new selector to dbt command
--- @param self dbtCommand
--- @param selector string | nil
dbtCommand.add_selector = function(self, selector)
  if selector and string.match(selector, '%%') then
    local path = Path:new(vim.api.nvim_buf_get_name(0))
    local buf_split = path:_split(path._sep)
    local file_name = buf_split[#buf_split]
    local model_name = vim.split(file_name, '%.')[1]
    selector = string.gsub(self.args.selector, '%%', model_name)
  elseif selector == '' then
    selector = nil
  end
  self.args.selector = selector
end

--- Add new arguments to the dbt command
--- @param self dbtCommand
--- @param extra_args table<string, string>
dbtCommand.add_extra_args = function(self, extra_args)
  self.args.extra_args = self.args.extra_args or {}
  for k, v in pairs(extra_args) do
    table.insert(self.args.extra_args, k)
    table.insert(self.args.extra_args, v)
  end
end

--- Add new flags to the dbt command
--- @param self dbtCommand
--- @param flags string[]
dbtCommand.add_extra_flags = function(self, flags)
  self.args.flags = self.args.flags or {}
  for i = 1, #flags do
    table.insert(self.args.flags, flags[i])
  end
end

--- Returns command as list of strings, compatible with vim.system()
--- @param self dbtCommand
--- @return string[]
dbtCommand.get_command = function(self)
  local cmd = { 'dbt', self.command }
  if self.args.selector then
    vim.list_extend(cmd, { '-s', self.args.selector })
  end
  for k, v in pairs(self.args.extra_args) do
    vim.list_extend(cmd, { ('--%s'):format(k), v })
  end
  vim.list_extend(cmd, self.args.flags or {})
  return cmd
end

--- Returns command as a single string
--- @param self dbtCommand
--- @return string
dbtCommand.get_string_command = function(self)
  return table.concat(self:get_command(), ' ')
end

--- Executes dbt command
--- @param self dbtCommand
--- @param callback function Called after command completed async. Receives sys.SystemObj.
--- If not passed, execution is synchronous and vim.SystemCompleted is returned.
--- @overload fun(self: dbtCommand): vim.SystemCompleted
--- @overload fun(self: dbtCommand, callback: function): vim.SystemObj
dbtCommand.execute = function(self, callback)
  local cmd = self:get_command()
  if callback then
    return vim.system(cmd, { text = true }, vim.schedule_wrap(callback))
  else
    return vim.system(cmd, { text = true }):wait()
  end
end

return dbtCommand
