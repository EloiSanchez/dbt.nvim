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
      { nargs = '?', desc = { 'Open buffer of model reference in current line' } }
    )

    -- dbt show command
    vim.api.nvim_buf_create_user_command(ev.buf, 'DbtShow', function(opts)
      executor.show(opts)
    end, {
      nargs = '?',
      range = '%',
      desc = { 'Execute dbt show command. Requires `dbt-core>=1.9.0`' },
    })

    -- dbt generate source yaml
    vim.api.nvim_buf_create_user_command(ev.buf, 'DbtGenerateModelYaml', function(opts)
      executor.generate_model_yaml(opts.fargs[1])
    end, {
      nargs = '?',
      desc = { 'Generate model yaml. Requires `dbt-codegen` library' },
      complete = 'dir',
    })
  end,
})
