local navigation = require('dbt.navigation')
local executor = require('dbt.executor')
local models = require('dbt.models')

vim.api.nvim_create_autocmd({ 'BufAdd', 'VimEnter' }, {
  pattern = '*.sql',
  callback = function(ev)
    vim.notify('Creating autocmds for dbt')

    -- Shorter alias
    local create_dbt_user_command = function(name, command, opts)
      vim.api.nvim_buf_create_user_command(ev.buf, name, command, opts)
    end

    -- For dryness
    local create_executable_generic_dbt_command = function(name)
      local mapping =
        { DbtRun = 'run', DbtBuild = 'build', DbtTest = 'test', DbtCompile = 'compile' }
      create_dbt_user_command(name, function(opts)
        executor.dbt_command(mapping[name], opts.args)
      end, {
        nargs = '?',
        desc = { ('Execute dbt %s command'):format(mapping[name]) },
        complete = models.completion,
      })
    end

    -- dbt generic commands
    create_executable_generic_dbt_command('DbtRun')
    create_executable_generic_dbt_command('DbtBuild')
    create_executable_generic_dbt_command('DbtTest')
    -- TODO: should parse and pretty print output in case a single model is selected
    create_executable_generic_dbt_command('DbtCompile')

    -- Open windows
    create_dbt_user_command(
      'DbtOpenTerm',
      executor.open_term,
      { desc = 'Open window with stdout from termial executions of dbt' }
    )
    create_dbt_user_command(
      'DbtOpenShowResults',
      executor.open_show_results,
      { desc = 'Open window with results of show command' }
    )

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
