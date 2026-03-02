local navigation = require('dbt.navigation')

vim.api.nvim_create_autocmd({ 'BufAdd', 'VimEnter' }, {
  pattern = '*.sql',
  callback = function(ev)
    vim.notify('Creating autocmd for dbt')
    vim.api.nvim_buf_create_user_command(
      ev.buf,
      'DbtGoToDefinition',
      navigation.go_to_definition,
      { nargs = '?' }
    )
  end,
})
