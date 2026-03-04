# `dbt.nvim`

> [!WARNING]
> This repository is not ready for production and, for now, is just a learning project for myself.
> See (although they all seem stale and unfinished):
>
> - [`cfmeyers/dbt.nvim`](https://github.com/cfmeyers/dbt.nvim): Has a few more features
> - [`alhankeser/dbt-nvim`](https://github.com/alhankeser/dbt-nvim): Implements the show command
> - [`3fonov/dbt-nvim`](https://github.com/3fonov/dbt-nvim): Has a few more features
> - [`yusufshalaby/dbt.nvim`](https://github.com/yusufshalaby/dbt.nvim): Has a few more features

[dbt](https://www.getdbt.com/) is a pretty common tool for Data Engineers / Analytics Engineers working in the transformation section of the data pipeline. It is a code-first tool with lots of possible integrations with editors (see [VSCode Extension](https://marketplace.visualstudio.com/items?itemName=dbtLabsInc.dbt&ssr=false#overview)), but there does not seem to be much for Neovim users. Therefore, this seems as good as any other place to start a learning project for myself.

Of course, issues, contributions, ideas... are all welcome. Just keep in mind, this is not meant to be a production ready tool any time soon.

## Roadmap

As a usual dbt-core user, this is a non-extensive list of features I would like to see in a dbt plugin.

- [x] Go to definition
- [ ] Go to references
- [ ] Show lineage
- [ ] dbt commands
  - [ ] Run
  - [ ] Test
  - [ ] Build
  - [ ] Compile
  - [x] Show (Async implemented)
- [ ] Show compiled code
- [ ] Show execution code

## Notes

- As a proof of concept, its going well so far, but it needs to have a well thought out architecture if it is to become more than a proof of concept.
- So far, tested with `dbt-core==1.11.6` and `dbt-duckdb=1.10.1`. No idea the changes required, if any, to make this work with the [dbt Fusion Engine](https://docs.getdbt.com/docs/fusion)
