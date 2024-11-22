import Config

config :app, App.Repo,
  database: "app",
  hostname: "localhost",
  port: 5433

config :app, App.ObanRepo,
  database: "oban",
  hostname: "localhost",
  port: 5434

config :app, Oban,
  engine: Oban.Engines.Basic,
  queues: [default: 10],
  repo: App.ObanRepo,
  get_dynamic_repo: fn -> if App.Repo.in_transaction?(), do: App.Repo, else: App.ObanRepo end

config :app, ecto_repos: [App.Repo, App.ObanRepo]
