import Config

config :ecto_soft_delete, ecto_repos: [Ecto.SoftDelete.Test.Repo]

config :ecto_soft_delete, Ecto.SoftDelete.Test.Repo,
  database: "soft_delete_test",
  hostname: "localhost",
  port: 5432,
  pool: Ecto.Adapters.SQL.Sandbox,
  types: EctoSoftDelete.PostgresTypes
