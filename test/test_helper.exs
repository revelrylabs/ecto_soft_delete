{:ok, _} = Application.ensure_all_started(:postgrex)
{:ok, _pid} = Ecto.SoftDelete.Test.Repo.start_link

defmodule Ecto.SoftDelete.Test.Migrations do
  use Ecto.Migration
  import Ecto.SoftDelete.Migration

  def change do
    drop_if_exists table(:users)
    create table(:users) do
      add :email, :string
      soft_delete_columns()
    end

    create table(:nondeletable) do
      add :value, :string
    end
  end
end

_ = Ecto.Migrator.up(Ecto.SoftDelete.Test.Repo, 0, Ecto.SoftDelete.Test.Migrations, log: false)
ExUnit.start()

Ecto.Adapters.SQL.Sandbox.mode(Ecto.SoftDelete.Test.Repo, :manual)
