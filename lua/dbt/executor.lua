local executor = {}

--- @class dbtCommand
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

dbtCommand.execute = function(self)
  local cmd_str = ('dbt %s %s'):format(self.command, table.concat(self.args, ' '))
  local file_handle = assert(io.popen(cmd_str))

  if file_handle then
    return file_handle:read('*a')
  end
end

--- Execute dbt show command. Accepts range with format as passed as command_args from
--- vim.api.nvim_create_user_command
--- @param opts vim.api.keyset.create_user_command.command_args
--- @return result[]
executor.show = function(opts)
  local query_lines = vim.api.nvim_buf_get_lines(0, opts.line1 - 1, opts.line2, true)

  local query = table.concat(query_lines, '\n')

  local dbt_show =
    dbtCommand.new('show', { '--quiet', '--inline', '"' .. query .. '"', '--output', 'json' })

  local output = vim.fn.json_decode(dbt_show:execute())['show']

  return output
end

return executor
