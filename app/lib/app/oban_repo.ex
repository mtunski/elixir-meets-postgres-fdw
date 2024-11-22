defmodule App.ObanRepo do
  use Ecto.Repo,
    otp_app: :app,
    adapter: Ecto.Adapters.Postgres
end
