# `dbt.nvim`

> [!NOTE]
> I started this project as a learning process for neovim and lua. At my job, I often have to use dbt and I had some ideas on how I wanted some features to be integrated.
>
> May be rough around the edges, since it has not been tested extensively
>
> Comments, issues, (constructive) criticism are welcome!

> [!NOTE]
> Dbt commands require `dbt-core>=1.9.0`, since the `--quiet` option that is used when interacting with dbt produces no output in previous versions.

[dbt](https://www.getdbt.com/) is a pretty common tool for Data Engineers / Analytics Engineers working in the transformation section of the data pipeline. It is a code-first tool with lots of possible integrations with editors (see [VSCode Extension](https://marketplace.visualstudio.com/items?itemName=dbtLabsInc.dbt&ssr=false#overview)), but there does not seem to be much for Neovim users. Therefore, this seems as good as any other place to start a learning project for myself.

## Usage

See [USAGE](https://github.com/EloiSanchez/dbt.nvim/blob/main/USAGE.md).

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
- [ ] Add healthcheck
- [ ] Find project root, potentially changing executable for dbt dynamically
- [ ] Add config options

## Notes

- As a proof of concept, its going well so far, but it needs to have a well thought out architecture if it is to become more than a proof of concept.
- So far, tested with `dbt-core==1.11.6` and `dbt-duckdb=1.10.1`. No idea the changes required, if any, to make this work with the [dbt Fusion Engine](https://docs.getdbt.com/docs/fusion)
- No AI has been used for this. All bugs and bad design choices are introduced by me. Therefore, if you have (constructive) criticism it is not only welcome, but wanted, since it will be used to make me a better developer. Thanks!
- Other similar plugins:
  - [`gbakes/dbt-forge`](https://github.com/gbakes/dbt-forge): The most recently maintained option I have found
  - [`cfmeyers/dbt.nvim`](https://github.com/cfmeyers/dbt.nvim)
  - [`alhankeser/dbt-nvim`](https://github.com/alhankeser/dbt-nvim)
  - [`3fonov/dbt-nvim`](https://github.com/3fonov/dbt-nvim)
  - [`yusufshalaby/dbt.nvim`](https://github.com/yusufshalaby/dbt.nvim)
