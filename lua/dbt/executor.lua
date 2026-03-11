local classes = require('dbt.classes')
local dbtCommand = classes.dbtCommand
local Display = require('dbt.display')

local executor = {}

--- Execute dbt show command. Accepts range with format as passed as command_args from
--- vim.api.nvim_create_user_command
--- @param opts vim.api.keyset.create_user_command.command_args
executor.show = function(opts)
  ---@param sys_completed vim.SystemCompleted
  local function parse_show_results(sys_completed)
    local success, output = pcall(vim.json.decode, sys_completed.stdout)

    --- @type result[]
    local results

    if success then
      results = output['show']
    else
      return vim.split(sys_completed.stdout, '\n')
    end

    -- PARSE RESULTS

    -- If results is empty then exit
    if #results == 0 then
      vim.notify('No data returned from show command', vim.log.levels.WARN)
      return { 'No data returned from show command' }
    end

    -- Get table with unique columns, which will also store the max length
    -- found required to print the column
    local columns = {}

    local _, first_row = next(results, nil)
    --- @diagnostic disable-next-line: param-type-mismatch
    for col, _ in pairs(first_row) do
      columns[col] = string.len(col)
    end

    -- Go over all values and store their length if its the largest value found
    for _, result in pairs(results) do
      for col, val in pairs(result) do
        local val_len = string.len(tostring(val))

        if val_len > columns[col] then
          columns[col] = val_len
        end
      end
    end

    -- Start string formatting to display table. Start with header and separator (split)
    local header = {}
    local split = {}
    for col, len in pairs(columns) do
      table.insert(header, string.format(' %-' .. len .. 's ', col))
      table.insert(split, string.format(' %-' .. len .. 's ', string.rep('-', len)))
    end

    local string_display =
      { '|' .. table.concat(header, '|') .. '|', '|' .. table.concat(split, '|') .. '|' }

    -- For each row of results, format a new string line
    for _, result in pairs(results) do
      local row = {}
      for col, len in pairs(columns) do
        table.insert(row, string.format(' %-' .. len .. 's ', result[col]))
      end
      table.insert(string_display, '|' .. table.concat(row, '|') .. '|')
    end

    return string_display
  end

  -- Get query lines from current buffer according to selection passed by user command opts
  local query_lines = vim.api.nvim_buf_get_lines(0, opts.line1 - 1, opts.line2, true)
  local query = table.concat(query_lines, '\n')

  -- Create placeholder text
  local placeholder = {
    '-- Executing show command...',
    '',
  }
  vim.list_extend(placeholder, query_lines)

  -- Open new results window with placeholder text
  local display = Display.new()
  display:open_results_window(placeholder, 'sql')

  -- Create dbt command and execute it async. Results are parsed and sent to display for writing to buffer
  dbtCommand.new('show', { '--quiet', '--inline', query, '--output', 'json' }):execute(function(obj)
    display:write_to_results(parse_show_results(obj), 'markdown')
  end)
end

--- Generate model yaml and open in buffer
--- @param opts vim.api.keyset.create_user_command.command_args
executor.generate_model_yaml = function(opts)
  local buf = vim.api.nvim_get_current_buf()
  local buf_name = vim.api.nvim_buf_get_name(buf)
  local display = Display.new()

  local path = require('plenary.path')
  local buf_path = path.new(buf_name)
  local splitted = buf_path:_split(buf_path._sep)
  local base_name = string.match(splitted[#splitted], '(.*)%psql')

  local yaml_buffer = display.open_buffer_in_current_window(0, { '# Loading results' }, 'yaml')
  dbtCommand
    .new(
      'run-operation',
      { '--quiet', 'generate_model_yaml', '--args', ('{"model_names": ["%s"]}'):format(base_name) }
    )
    :execute(function(obj)
      display.write_out_to_buffer(yaml_buffer, obj.stdout, obj.stderr)
    end)
end
return executor
