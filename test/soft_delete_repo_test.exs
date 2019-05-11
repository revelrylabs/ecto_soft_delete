defmodule Ecto.SoftDelete.Repo.Test do
  use ExUnit.Case
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

  describe "soft_delete!/1" do
    test "should soft delete the queryable" do
      user = Repo.insert!(%User{email: "test0@example.com"})

      assert %User{} = Repo.soft_delete!(user)

      assert %DateTime{} = Repo.get_by!(User, email: "test0@example.com").deleted_at
    end

    test "should return an error deleting" do
      user = Repo.insert!(%User{email: "test0@example.com"})
      Repo.delete!(user)

      assert_raise Ecto.StaleEntryError, fn ->
        Repo.soft_delete!(user)
      end
    end
  end

  describe "soft_delete/1" do
    test "should soft delete the queryable" do
      user = Repo.insert!(%User{email: "test0@example.com"})

      assert {:ok, %User{}} = Repo.soft_delete(user)

      assert %DateTime{} = Repo.get_by!(User, email: "test0@example.com").deleted_at
    end

    test "should return an error deleting" do
      user = Repo.insert!(%User{email: "test0@example.com"})
      Repo.delete!(user)

      assert_raise Ecto.StaleEntryError, fn ->
        Repo.soft_delete(user)
      end
    end
  end

  describe "soft_delete_all/1" do
    test "soft deleted the query" do
      Repo.insert!(%User{email: "test0@example.com"})
      Repo.insert!(%User{email: "test1@example.com"})
      Repo.insert!(%User{email: "test2@example.com"})

      assert Repo.soft_delete_all(User) == {3, nil}

      assert User |> Repo.all() |> length() == 3

      assert %DateTime{} = Repo.get_by!(User, email: "test0@example.com").deleted_at
      assert %DateTime{} = Repo.get_by!(User, email: "test1@example.com").deleted_at
      assert %DateTime{} = Repo.get_by!(User, email: "test2@example.com").deleted_at
    end

    test "when no results are found" do
      assert Repo.soft_delete_all(User) == {0, nil}
    end
  end
end
