defmodule Ecto.SoftDelete.Repo.Test do
  use ExUnit.Case
  alias Ecto.SoftDelete.Test.Repo
  import Ecto.Query

  defmodule User do
    use Ecto.Schema
    import Ecto.SoftDelete.Schema

    schema "users" do
      field(:email, :string)
      soft_delete_schema()
    end
  end

  defmodule Nondeletable do
    use Ecto.Schema

    schema "nondeletable" do
      field(:value, :string)
    end
  end

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Ecto.SoftDelete.Test.Repo)
  end

  describe "soft_delete!/1" do
    test "should soft delete the queryable" do
      user = Repo.insert!(%User{email: "test0@example.com"})

      assert %User{} = Repo.soft_delete!(user)

      assert %DateTime{} =
               Repo.get_by!(User, [email: "test0@example.com"], with_deleted: true).deleted_at
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

      assert %DateTime{} =
               Repo.get_by!(User, [email: "test0@example.com"], with_deleted: true).deleted_at
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

      assert User |> Repo.all(with_deleted: true) |> length() == 3

      assert %DateTime{} =
               Repo.get_by!(User, [email: "test0@example.com"], with_deleted: true).deleted_at

      assert %DateTime{} =
               Repo.get_by!(User, [email: "test1@example.com"], with_deleted: true).deleted_at

      assert %DateTime{} =
               Repo.get_by!(User, [email: "test2@example.com"], with_deleted: true).deleted_at
    end

    test "when no results are found" do
      assert Repo.soft_delete_all(User) == {0, nil}
    end
  end

  describe "soft_restore/1" do
    test "should soft restore the queryable" do
      Repo.insert!(%User{email: "test0@example.com"}) |> Repo.soft_delete(Repo) |> Repo.soft_restore(Repo)

      assert Repo.get_by!(User, [email: "test0@example.com"], with_deleted: true).deleted_at ==
               nil
    end
  end

  describe "soft_restore_all/1" do
    test "soft deleted the query" do
      Repo.insert!(%User{email: "test0@example.com"})
      Repo.insert!(%User{email: "test1@example.com"})
      Repo.insert!(%User{email: "test2@example.com"})

      assert Repo.soft_delete_all(User) == {3, nil}

      assert User |> Repo.all(with_deleted: true) |> length() == 3

      assert %DateTime{} =
               Repo.get_by!(User, [email: "test0@example.com"], with_deleted: true).deleted_at

      assert %DateTime{} =
               Repo.get_by!(User, [email: "test1@example.com"], with_deleted: true).deleted_at

      assert %DateTime{} =
               Repo.get_by!(User, [email: "test2@example.com"], with_deleted: true).deleted_at

      assert Repo.soft_restore_all(%User{}, Repo) == {3, nil}

      assert User |> Repo.all(with_deleted: true) |> length() == 3

      assert Repo.get_by!(User, [email: "test0@example.com"], with_deleted: true).deleted_at ==
               nil

      assert Repo.get_by!(User, [email: "test1@example.com"], with_deleted: true).deleted_at ==
               nil

      assert Repo.get_by!(User, [email: "test2@example.com"], with_deleted: true).deleted_at ==
               nil
    end

    test "when no results are found" do
      assert Repo.soft_delete_all(User) == {0, nil}
    end
  end

  describe "prepare_query/3" do
    test "excludes soft deleted records by default" do
      user = Repo.insert!(%User{email: "test0@example.com"})

      soft_deleted_user =
        Repo.insert!(%User{email: "deleted@example.com", deleted_at: DateTime.utc_now()})

      results = User |> Repo.all()

      assert Enum.member?(results, user)
      refute Enum.member?(results, soft_deleted_user)
    end

    test "includes soft deleted records if :with_deleted option is present" do
      user = Repo.insert!(%User{email: "test0@example.com"})

      soft_deleted_user =
        Repo.insert!(%User{email: "deleted@example.com", deleted_at: DateTime.utc_now()})

      results = User |> Repo.all(with_deleted: true)

      assert Enum.member?(results, user)
      assert Enum.member?(results, soft_deleted_user)
    end

    test "includes soft deleted records if where not is_nil(deleted_at) clause is present" do
      user = Repo.insert!(%User{email: "test0@example.com"})

      soft_deleted_user =
        Repo.insert!(%User{email: "deleted@example.com", deleted_at: DateTime.utc_now()})

      results =
        User
        |> where([u], not is_nil(u.deleted_at))
        |> Repo.all()

      refute Enum.member?(results, user)
      assert Enum.member?(results, soft_deleted_user)
    end

    test "works with schemas that don't have deleted_at column" do
      Repo.insert!(%Nondeletable{value: "stuff"})
      results = Nondeletable |> Repo.all()

      assert length(results) == 1
    end
  end
end
