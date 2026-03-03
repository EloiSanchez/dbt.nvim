local display = {}

--- @param results result[]
display.show_table = function(results)
  -- If results is empty then exit
  if #results == 0 then
    vim.notify('No data returned from show command', vim.log.levels.WARN)
    return
  end

  -- Get table with unique columns, which will also store the max length
  -- found required to print the column
  local columns = {}

  local _, first_row = next(results, nil)
  --- @diagnostic disable-next-line: param-type-mismatch
  for k, _ in pairs(first_row) do
    columns[k] = string.len(k)
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

  -- Create buffer
  local buf = vim.api.nvim_create_buf(true, true)
  vim.bo[buf].filetype = 'markdown'

  -- Add lines to buffer
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, string_display)

  -- Keymap to exit and avoid user modifying it
  vim.api.nvim_buf_set_keymap(buf, 'n', 'q', ':q', { desc = 'dbt - Close results window' })
  vim.bo[buf].modifiable = false

  -- Create and open window below current window
  vim.api.nvim_open_win(buf, false, { split = 'below', height = math.floor(vim.o.lines * 0.3) })
end

return display
