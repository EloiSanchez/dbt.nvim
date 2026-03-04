local navigation = require('dbt.navigation')
local executor = require('dbt.executor')

vim.api.nvim_create_autocmd({ 'BufAdd', 'VimEnter' }, {
  pattern = '*.sql',
  callback = function(ev)
    vim.notify('Creating autocmds for dbt')

    -- vim.print(ev)
    -- Go to definition
    vim.api.nvim_buf_create_user_command(
      ev.buf,
      'DbtGoToDefinition',
      navigation.go_to_definition,
      { nargs = '?' }
    )

    -- dbt show command
    vim.api.nvim_buf_create_user_command(ev.buf, 'DbtShow', function(opts)
      executor.show(opts)
    end, { nargs = '?', range = '%' })
  end,
})
