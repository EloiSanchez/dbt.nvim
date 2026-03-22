local navigation = require('dbt.navigation')
local executor = require('dbt.executor')

vim.api.nvim_create_autocmd({ 'BufAdd', 'VimEnter' }, {
  pattern = '*.sql',
  callback = function(ev)
    vim.notify('Creating autocmds for dbt')

    local create_dbt_user_command = function(name, command, opts)
      vim.api.nvim_buf_create_user_command(ev.buf, name, command, opts)
    end

    -- Go to definition
    create_dbt_user_command(
      'DbtGoToDefinition',
      navigation.go_to_definition,
      { nargs = '?', desc = { 'Open buffer of model reference in current line' } }
    )

    -- dbt show command
    create_dbt_user_command('DbtShow', function(opts)
      executor.dbt_show(0, opts.line1, opts.line2)
    end, {
      nargs = '?',
      range = '%',
      desc = { 'Execute dbt show command. Requires `dbt-core>=1.9.0`' },
    })

    -- dbt run command
    create_dbt_user_command(
      'DbtRun',
      ---@param opts vim.api.keyset.create_user_command.command_args
      function(opts)
        -- By default run full dbt project
        local selector = nil

        -- If args passed, parse to use as selector
        selector = opts.args

        -- Run dbt with parsed selector
        executor.dbt_run(selector)
      end,
      {
        nargs = '?',
        desc = { 'Execute dbt run command.' },
      }
    )

    -- dbt generate source yaml
    create_dbt_user_command('DbtGenerateModelYaml', function(opts)
      executor.generate_model_yaml(opts.fargs[1])
    end, {
      nargs = '?',
      desc = { 'Generate model yaml. Requires `dbt-codegen` library' },
      complete = 'dir',
    })
  end,
})
