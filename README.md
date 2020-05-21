# Tomlrex - TOML parser library for Elixir using Rust bindings

## Just to play with `rustler`

## Parsing API is similar to `toml-elixir` but with some difference

Difference with `toml-elixir` parsing:

- Zeros are striped from times:

```elixir
toml_expected = ~U[2018-06-30 12:30:58.030Z]
{:ok, %{"n" => ^toml_expected}} = Toml.decode("n = 2018-06-30 12:30:58.030Z")

tomlrex_expected = ~U[2018-06-30 12:30:58.03Z]
{:ok, %{"n" => ^tomlrex_expected}} = Tomlrex.decode("n = 2018-06-30 12:30:58.030Z")
```

- Heterogeneous arrays are allowed
- No options are allowed (at least for now) in functions
- Transforms won't be implemented.

# TODO:

* add tests against `toml-test`
* add linters to check rust (clappy) and elixir (credo) code style.
* add CI for running tests
