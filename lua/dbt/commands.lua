local navigation = require('dbt.navigation')
local executor = require('dbt.executor')
local Path = require('plenary.path')

vim.api.nvim_create_autocmd({ 'BufAdd', 'VimEnter' }, {
  pattern = '*.sql',
  callback = function(ev)
    vim.notify('Creating autocmds for dbt')

    local create_dbt_ac = function(name, command, opts)
      vim.api.nvim_buf_create_user_command(ev.buf, name, command, opts)
    end

    -- vim.print(ev)
    -- Go to definition
    create_dbt_ac(
      'DbtGoToDefinition',
      navigation.go_to_definition,
      { nargs = '?', desc = { 'Open buffer of model reference in current line' } }
    )

    -- dbt show command
    create_dbt_ac('DbtShow', function(opts)
      executor.dbt_show(0, opts.line1, opts.line2)
    end, {
      nargs = '?',
      range = '%',
      desc = { 'Execute dbt show command. Requires `dbt-core>=1.9.0`' },
    })

    -- dbt run command
    create_dbt_ac(
      'DbtRun',
      ---@param opts vim.api.keyset.create_user_command.command_args
      function(opts)
        -- By default run full dbt project
        local selector = nil

        -- Run dbt with passed selector
        if opts.args ~= '' and opts.args ~= '%' then
          selector = opts.args

        -- Run model in current buffer
        elseif opts.args == '%' then
          local path = Path:new(vim.api.nvim_buf_get_name(0))
          local buf_split = path:_split(path._sep)
          local file_name = buf_split[#buf_split]
          selector = vim.split(file_name, '%.')[1]
        end

        -- Run dbt with parsed selector
        executor.dbt_run(selector)
      end,
      {
        nargs = '?',
        desc = { 'Execute dbt show command. Requires `dbt-core>=1.9.0`' },
      }
    )

    -- dbt generate source yaml
    create_dbt_ac('DbtGenerateModelYaml', function(opts)
      executor.generate_model_yaml(opts.fargs[1])
    end, {
      nargs = '?',
      desc = { 'Generate model yaml. Requires `dbt-codegen` library' },
      complete = 'dir',
    })
  end,
})
