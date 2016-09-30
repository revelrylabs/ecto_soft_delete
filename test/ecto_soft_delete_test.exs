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

  setup _ do
    config = Application.get_env(:ecto_soft_delete, Ecto.SoftDelete.Test.Repo)
    postgrex_config = [
      database: config[:database],
      hostname: config[:hostname],
      port: config[:port]
    ]

    {:ok, pid} = Postgrex.start_link(postgrex_config)
    {:ok, _} = Postgrex.query(pid, "DROP TABLE IF EXISTS users", [])
    {:ok, _} = Postgrex.query(pid, "CREATE TABLE users (id serial primary key, email text, deleted_at timestamp without time zone)", [])
    {:ok, _} = Repo.start_link()

    :ok
  end

  test "User has deleted_at field" do
    Repo.insert!(%User{email: "test@example.com"})
    query = from u in User, select: u
    results = Repo.all(query)

    assert nil == hd(results).deleted_at
  end


  test "with_deleted on returns undeleted users" do
    Repo.insert!(%User{email: "test@example.com"})
    Repo.insert!(%User{email: "test@example.com", deleted_at: Ecto.DateTime.utc})

    query = from(u in User, select: u)
    |> with_undeleted

    results = Repo.all(query)

    assert 1 == length(results)
  end
end
