defmodule Ecto.SoftDelete.Test.Migrations do
  use Ecto.Migration
  import Ecto.SoftDelete.Migration

  def change do
    drop_if_exists table(:users)
    create table(:users) do
      add :email, :string
      soft_delete_columns
    end
  end
end
