defmodule Ecto.SoftDelete.Query do
  @moduledoc """
  functions for querying data that is (or is not) soft deleted
  """

  import Ecto.Query

  @doc """
  Returns a query that searches only for undeleted items

      query = from(u in User, select: u)
      |> with_undeleted

      results = Repo.all(query)

  """
  @spec with_undeleted(Ecto.Queryable.t) :: Ecto.Queryable.t
  def with_undeleted(query) do
    query
    |> where([t], is_nil(t.deleted_at))
  end
end
