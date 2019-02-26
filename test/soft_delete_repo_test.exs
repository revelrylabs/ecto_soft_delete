defmodule Ecto.SoftDelete.Repo.Test do
  use ExUnit.Case
  import Ecto.Query
  alias Ecto.SoftDelete.Test.Repo

  defmodule User do
    use Ecto.Schema
    import Ecto.SoftDelete.Schema

    schema "users" do
      field(:email, :string)
      soft_delete_schema()
    end
  end

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Ecto.SoftDelete.Test.Repo)
  end

  describe "soft_delete_all" do
    test "soft deleted the query" do
      Repo.insert!(%User{email: "test0@example.com"})
      Repo.insert!(%User{email: "test1@example.com"})
      Repo.insert!(%User{email: "test2@example.com"})

      assert Repo.soft_delete_all(User) == {3, nil}

      assert User |> Repo.all() |> length() == 3

      assert Repo.get_by!(User, email: "test0@example.com").deleted_at != nil
      assert Repo.get_by!(User, email: "test1@example.com").deleted_at != nil
      assert Repo.get_by!(User, email: "test2@example.com").deleted_at != nil
    end

    test "when no results are found" do
      assert Repo.soft_delete_all(User) == {0, nil}
    end
  end
end
