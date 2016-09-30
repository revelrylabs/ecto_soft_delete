{:ok, _} = Application.ensure_all_started(:postgrex)
{:ok, _pid} = Ecto.SoftDelete.Test.Repo.start_link
_ = Ecto.Migrator.up(Ecto.SoftDelete.Test.Repo, 0, Ecto.SoftDelete.Test.Migrations, log: false)
ExUnit.start()

Ecto.Adapters.SQL.Sandbox.mode(Ecto.SoftDelete.Test.Repo, :manual)
