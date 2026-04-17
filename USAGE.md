# dbt.nvim

Simple utilities to facilitate working in dbt-core projects from within neovim.

# Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "EloiSanchez/dbt.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
}
```

# dbt commands

dbt commands can be executed from the neovim command line with the following syntax (example with `dbt build`)

```bash
:DbtBuild [[@|+]dbt_model_selection][*]]
```

for instance

```bash
:DbtBuild orders+,@customers
```

will open a docked window where the results of the dbt execution are shown. This window can be closed by pressing `q` and can be reopened without losing information about past executions with [:DbtOpenTerm](#:dbtopenterm).

| Available dbt commands      |
| --------------------------- |
| [dbt build](#:dbtbuild)     |
| [dbt run](#:dbtrun)         |
| [dbt compile](#:dbtcompile) |
| [dbt seed](#:dbtseed)       |
| [dbt test](#:dbttest)       |

### Using `%` for current buffer

The special character `%` will be replaced by the current's buffer model name. Therefore, if current buffer is `./models/silver/employees.sql` then:

```bash
:DbtBuild %+
```

is translated to

```bash
:DbtBuild emplyees+
```

## :DbtBuild [dbt_model_selection]

Executes `dbt build`

## :DbtRun [dbt_model_selection]

Executes `dbt run`

## :DbtCompile [dbt_model_selection]

Executes `dbt compile`

## :DbtSeed [dbt_model_selection]

Executes `dbt seed`

## :DbtTest [dbt_model_selection]

Executes `dbt test`

## :DbtOpenTerm

Opens docked window showing past executions of [dbt commands](#:dbt-commands).

# dbt show

## :{Visual}DbtShow

Executes the _current_ buffer code against the database and show the results.

If used in visual mode, only the selected range is executed.

The automatically opened docked window can be closed by pressing `q` in it and can be reopened later without losing the previous results with [:DbtOpenShowResults](#:dbtopenshowresults).

## :DbtOpenShowResults

Opens docked window showing past executions of [:DbtShow](#:{visual}dbtshow).

# Navigation

## :DbtGoToDefinition

Jump to the model under the cursor referenced by a `{{ ref(...) }}` snippet.

## :DbtGoToReferences

Opens quickfix list of references to model opened in current buffer.

# Code generation

## :DbtGenerateModelYaml [yaml_save_path]

Open a buffer with yaml definition of current model. If `yaml_save_path` is passed, the buffer will be created on the specified path, ready to be written. Otherwise, the generated yaml is opened on a scratch buffer, where it can be yanked and closed (or `:h CTRL-O` to jump to previous location).
