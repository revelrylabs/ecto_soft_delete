defmodule Ecto.SoftDelete.Test do
  use ExUnit.Case
  import Ecto.Query
  import Ecto.SoftDelete.Query
  alias Ecto.SoftDelete.Test.Repo

  defmodule User do
    use Ecto.Schema
    import Ecto.SoftDelete.Schema

    schema "users" do
      field :email,           :string
      soft_delete_schema()
    end
  end

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  test "User has deleted_at field" do
    Repo.insert!(%User{email: "test@example.com"})
    query = from u in User, select: u
    results = Repo.all(query)

    assert nil == hd(results).deleted_at
  end


  test "with_deleted on returns undeleted users" do
    Repo.insert!(%User{email: "undeleted@example.com"})
    Repo.insert!(%User{email: "deleted@example.com", deleted_at: DateTime.utc_now()})

    query = from(u in User, select: u)
    |> with_undeleted

    results = Repo.all(query)

    assert 1 == length(results)
    assert "undeleted@example.com" == hd(results).email
  end
end
