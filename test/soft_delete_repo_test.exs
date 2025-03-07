defmodule Ecto.SoftDelete.Repo.Test do
  use ExUnit.Case
  alias Ecto.SoftDelete.Test.Repo
  import Ecto.Query
  import ExUnit.CaptureLog

  defmodule User do
    use Ecto.Schema
    import Ecto.SoftDelete.Schema

    schema "users" do
      field(:email, :string)
      soft_delete_schema()
    end
  end

  defmodule UserWithSkipPrepareQuery do
    use Ecto.Schema
    import Ecto.SoftDelete.Schema

    schema "users" do
      field(:email, :string)
      soft_delete_schema(auto_exclude_from_queries?: false)
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

  describe "soft_delete!/2 with options" do
    test "should soft delete the queryable and pass options to update!" do
      user = Repo.insert!(%User{email: "test0@example.com"})

      # Test with empty options list
      assert %User{} = Repo.soft_delete!(user, [])

      assert %DateTime{} =
               Repo.get_by!(User, [email: "test0@example.com"], with_deleted: true).deleted_at
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

  describe "soft_delete/2 with options" do
    test "should soft delete the queryable and pass options to update" do
      user = Repo.insert!(%User{email: "test0@example.com"})

      # Test with empty options list
      assert {:ok, %User{}} = Repo.soft_delete(user, [])

      assert %DateTime{} =
               Repo.get_by!(User, [email: "test0@example.com"], with_deleted: true).deleted_at
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

  describe "soft_delete_all/2 with options" do
    test "soft deletes the query and passes options to update_all" do
      Repo.insert!(%User{email: "test0@example.com"})
      Repo.insert!(%User{email: "test1@example.com"})

      # Test with empty options list
      assert Repo.soft_delete_all(User, []) == {2, nil}

      assert User |> Repo.all(with_deleted: true) |> length() == 2

      assert %DateTime{} =
               Repo.get_by!(User, [email: "test0@example.com"], with_deleted: true).deleted_at

      assert %DateTime{} =
               Repo.get_by!(User, [email: "test1@example.com"], with_deleted: true).deleted_at
    end

    test "soft deletes with log option" do
      Repo.insert!(%User{email: "test0@example.com"})

      log =
        capture_log(fn ->
          Repo.soft_delete_all(User, log: :info)
        end)

      assert log =~ "UPDATE"
      assert log =~ "deleted_at"
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

    test "handles subquery that does not expose deleted_at as 'main' schema" do
      Repo.insert!(%User{email: "test0@example.com"})
      Repo.insert!(%Nondeletable{value: "stuff"})

      subq = User |> where([u], u.email == "test0@example.com") |> select([u], %{id: u.id, email: u.email})
      query = subquery(subq) |> join(:left, [u], nondel in Nondeletable, on: u.id == nondel.id)

      Repo.all(query)
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

    test "includes soft deleted records if `auto_exclude_from_queries?` is false" do
      user = Repo.insert!(%UserWithSkipPrepareQuery{email: "test0@example.com"})

      soft_deleted_user =
        Repo.insert!(%UserWithSkipPrepareQuery{
          email: "deleted@example.com",
          deleted_at: DateTime.utc_now()
        })

      results = UserWithSkipPrepareQuery |> Repo.all()

      assert Enum.member?(results, user)
      assert Enum.member?(results, soft_deleted_user)
    end

    test "works with schemas that don't have deleted_at column" do
      Repo.insert!(%Nondeletable{value: "stuff"})
      results = Nondeletable |> Repo.all()

      assert length(results) == 1
    end

    test "returns same result for different types of where clauses" do
      _user = Repo.insert!(%User{email: "test0@example.com"})

      _soft_deleted_user =
        Repo.insert!(%User{email: "deleted@example.com", deleted_at: DateTime.utc_now()})

      query_1 =
        from(u in User,
          select: u,
          where: u.email == "test0@example.com" and not is_nil(u.deleted_at)
        )

      query_2 =
        from(u in User,
          select: u,
          where: u.email == "test0@example.com",
          where: not is_nil(u.deleted_at)
        )

      assert Repo.all(query_2) == Repo.all(query_1)
    end
  end
end
