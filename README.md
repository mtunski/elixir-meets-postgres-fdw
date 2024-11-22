## Setup

- install devbox: https://www.jetify.com/docs/devbox/installing_devbox/
- `cd code/elixir-meets-postgres-fdw`
- `devbox run initdb`
- `devbox services up postgresql_app postgresql_oban`

<!-- -->

- `devbox shell`
- `cd app`
- `mix deps.get`
- `mix ecto.create && mix ecto.migrate`
- `iex -S mix`
- `iex> App.insert_thing_and_work()`
