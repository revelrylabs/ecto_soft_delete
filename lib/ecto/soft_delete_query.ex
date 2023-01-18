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
    if soft_deletable?(query) do
      query
      |> where([t], is_nil(t.deleted_at))
    else
      query
    end
  end

  @doc """
  Determines if a given Ecto query is soft deletable.

  ### Parameters

      - `query`: An Ecto query struct.

  ### Returns

      - `true` if the query is soft deletable, `false` otherwise.
  """
  def soft_deletable?(query) do
    schema_module = get_schema_module_from_query(query)
    fields = if schema_module, do: schema_module.__schema__(:fields), else: []

    Enum.member?(fields, :deleted_at)
  end

  defp get_schema_module_from_query(%Ecto.Query{from: %{source: {_name, module}}}) do
    module
  end

  defp get_schema_module_from_query(_), do: nil
end
