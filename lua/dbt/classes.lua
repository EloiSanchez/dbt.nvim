--- Types

--- @alias result table<string, any>

--- Classes

--- @class dbtCommand
---
--- @field command string
--- @field args string[]
local dbtCommand = {}
dbtCommand.__index = dbtCommand

--- Create new dbt command
--- @param command string
--- @param args string[]
--- @return dbtCommand
dbtCommand.new = function(command, args)
  local self = setmetatable({}, dbtCommand)
  self.command = command
  self.args = args

  return self
end

--- Add new arguments to the dbt command
--- @param self dbtCommand
--- @param args string[]
dbtCommand.add_args = function(self, args)
  for i = 1, #args do
    table.insert(self.args, args[i])
  end
end

--- Returns command as list of strings, compatible with vim.system()
--- @param self dbtCommand
--- @return string[]
dbtCommand.get_command = function(self)
  local cmd = { 'dbt', self.command }
  vim.list_extend(cmd, self.args)
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

return {
  dbtCommand = dbtCommand,
}
