local dbt = require('dbt')

-- Autocommand group
local dbt_augroup = dbt.utils.get_dbt_augroup()

--
vim.api.nvim_create_autocmd({ 'FileType' }, {
  pattern = 'sql',
  group = dbt_augroup,
  callback = function(ev)
    vim.notify('Creating autocmds for dbt')

    -- Shorter alias
    local create_dbt_user_command = function(name, command, opts)
      vim.api.nvim_buf_create_user_command(ev.buf, name, command, opts)
    end

    -- For dryness
    local create_executable_generic_dbt_command = function(name)
      local mapping = {
        DbtRun = 'run',
        DbtBuild = 'build',
        DbtTest = 'test',
        DbtCompile = 'compile',
        DbtSeed = 'seed',
      }
      create_dbt_user_command(name, function(opts)
        dbt.executor.dbt_command(mapping[name], opts.args)
      end, {
        nargs = '?',
        desc = { ('Execute dbt %s command'):format(mapping[name]) },
        complete = dbt.utils.completion,
      })
    end

    -- dbt generic commands
    create_executable_generic_dbt_command('DbtRun')
    create_executable_generic_dbt_command('DbtBuild')
    create_executable_generic_dbt_command('DbtTest')
    create_executable_generic_dbt_command('DbtSeed')
    -- TODO: should parse and pretty print output in case a single model is selected
    create_executable_generic_dbt_command('DbtCompile')

    -- Open windows
    create_dbt_user_command(
      'DbtOpenTerm',
      dbt.executor.open_term,
      { desc = 'Open window with stdout from termial executions of dbt' }
    )
    create_dbt_user_command(
      'DbtOpenShowResults',
      dbt.executor.open_show_results,
      { desc = 'Open window with results of show command' }
    )

    -- Go to definition
    create_dbt_user_command(
      'DbtGoToDefinition',
      dbt.navigation.go_to_definition,
      { nargs = '?', desc = { 'Open buffer of model reference in current line' } }
    )

    -- Go to references
    create_dbt_user_command('DbtGoToReferences', dbt.navigation.go_to_references, {
      desc = {
        'Open location list with references of current model. If closed, can be reopened with `:lopen`.',
      },
    })

    -- dbt show command
    create_dbt_user_command('DbtShow', function(opts)
      dbt.executor.dbt_show(0, opts.line1, opts.line2)
    end, {
      nargs = '?',
      range = '%',
      desc = { 'Execute dbt show command. Requires `dbt-core>=1.9.0`' },
    })

    -- dbt generate source yaml
    create_dbt_user_command('DbtGenerateModelYaml', function(opts)
      dbt.executor.generate_model_yaml(opts.fargs[1])
    end, {
      nargs = '?',
      desc = { 'Generate model yaml. Requires `dbt-codegen` library' },
      complete = 'dir',
    })
  end,
})

return dbt
