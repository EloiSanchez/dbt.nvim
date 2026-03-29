# `dbt.nvim`

> [!NOTE]
> Project started as a learning experience and for self use. At this point, it implements quite a few useful utilities for working with dbt. However, it is has not been tested extensively with different versions, setups, ..., but `dbt-core>=1.9.0` should be enough for everything to work (plus `dbt-codegen`).
>
> Issues, contributions, notes, suggestions are all welcome and encouraged!

> [!NOTE]
> See other options:
>
> - [`gbakes/dbt-forge`](https://github.com/gbakes/dbt-forge): The most recently maintained option I have found
> - [`cfmeyers/dbt.nvim`](https://github.com/cfmeyers/dbt.nvim)
> - [`alhankeser/dbt-nvim`](https://github.com/alhankeser/dbt-nvim)
> - [`3fonov/dbt-nvim`](https://github.com/3fonov/dbt-nvim)
> - [`yusufshalaby/dbt.nvim`](https://github.com/yusufshalaby/dbt.nvim)

> [!INFO]
> Dbt show command requires `dbt-core>=1.9.0`

[dbt](https://www.getdbt.com/) is a pretty common tool for Data Engineers / Analytics Engineers working in the transformation section of the data pipeline. It is a code-first tool with lots of possible integrations with editors (see [VSCode Extension](https://marketplace.visualstudio.com/items?itemName=dbtLabsInc.dbt&ssr=false#overview)), but there does not seem to be much for Neovim users. Therefore, this seems as good as any other place to start a learning project for myself.

Of course, issues, contributions, ideas... are all welcome. Just keep in mind, this is not meant to be a production ready tool any time soon.

## Roadmap

As a usual dbt-core user, this is a non-extensive list of features I would like to see in a dbt plugin.

- [x] Go to definition
- [x] Go to references
  - [x] Via location list / quickfix list
  - [ ] Allows pickers like telescope or snacks
- [ ] Show lineage
- [x] dbt commands
  - [x] Run
  - [x] Test
  - [x] Build
  - [x] Compile
  - [x] Show (Async implemented) (requires `dbt-core>=1.9.0`)
- [ ] Show compiled code
- [ ] Show executed code
- [x] Generate model config via dbt-codegen
  - [x] Open model config file if has format `models/.../base_model_name.yml`
  - [ ] Open model config if found in _any_ config yaml file
- [ ] Provide snippets/autocompletion for double curlies (`{{...}}`) for common commands

## Notes

- As a proof of concept, its going well so far, but it needs to have a well thought out architecture if it is to become more than a proof of concept.
- So far, tested with `dbt-core==1.11.6` and `dbt-duckdb=1.10.1`. No idea the changes required, if any, to make this work with the [dbt Fusion Engine](https://docs.getdbt.com/docs/fusion)
