defmodule Ecto.SoftDelete.Repo do
  @moduledoc """
  Adds soft delete functions to an repository.

      defmodule Repo do
        use Ecto.Repo,
          otp_app: :my_app,
          adapter: Ecto.Adapters.Postgres
        use Ecto.SoftDelete.Repo
      end

  """

  @doc """
  Soft deletes all entries matching the given query.

  It returns a tuple containing the number of entries and any returned
  result as second element. The second element is `nil` by default
  unless a `select` is supplied in the update query.

  ## Examples

      MyRepo.soft_delete_all(Post)
      from(p in Post, where: p.id < 10) |> MyRepo.soft_delete_all()

  """
  @callback soft_delete_all(queryable :: Ecto.Queryable.t()) :: {integer, nil | [term]}

  @doc """
  Soft deletes a struct.
  Updates the `deleted_at` field with the current datetime in UTC.
  It returns `{:ok, struct}` if the struct has been successfully
  soft deleted or `{:error, changeset}` if there was a validation
  or a known constraint error.

  ## Examples

      post = MyRepo.get!(Post, 42)
      case MyRepo.soft_delete post do
        {:ok, struct}       -> # Soft deleted with success
        {:error, changeset} -> # Something went wrong
      end

  """
  @callback soft_delete(struct_or_changeset :: Ecto.Schema.t() | Ecto.Changeset.t()) ::
              {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}

  @doc """
  Same as `c:soft_delete/1` but returns the struct or raises if the changeset is invalid.
  """
  @callback soft_delete!(struct_or_changeset :: Ecto.Schema.t() | Ecto.Changeset.t()) ::
              Ecto.Schema.t()

  defmacro __using__(_opts) do
    quote do
      import Ecto.Query
      import Ecto.SoftDelete.Query

      def soft_delete_all(queryable) do
        update_all(queryable, set: [deleted_at: DateTime.utc_now()])
      end

      def soft_delete(struct_or_changeset) do
        struct_or_changeset
        |> Ecto.Changeset.change(deleted_at: DateTime.utc_now())
        |> update()
      end

      def soft_delete!(struct_or_changeset) do
        struct_or_changeset
        |> Ecto.Changeset.change(deleted_at: DateTime.utc_now())
        |> update!()
      end

      @doc """
      Overrides all query operations to exclude soft deleted records
      if the schema in the from clause has a deleted_at column
      NOTE: will not exclude soft deleted records if :with_deleted option passed as true
      """
      def prepare_query(_operation, query, opts) do
        if has_include_deleted_at_clause?(query) || opts[:with_deleted] || !soft_deletable?(query) do
          {query, opts}
        else
          query = filter_soft_deleted(query)
          {query, opts}
        end
      end

      # We need to check the entire query and apply filtering
      # where appropriate.  So, we recurse the query here and
      # rebuild it with filtering where appropriate.  This
      # currently only considers the source and does not handle
      # things like joins...
      defp filter_soft_deleted(%Ecto.Query{from: %{source: {_schema, _module}}} = query) do
        if Ecto.SoftDelete.Query.soft_deletable?(query) do
          from(x in query, where: is_nil(x.deleted_at))
        else
          query
        end
      end

      defp filter_soft_deleted(%Ecto.SubQuery{query: query} = sub) do
        if Ecto.SoftDelete.Query.soft_deletable?(query) do
          from(x in query, where: is_nil(x.deleted_at)) |> subquery()
        else
          sub
        end
      end

      defp filter_soft_deleted(%Ecto.Query{from: from} = query) do
        updated_from = %{from | source: filter_soft_deleted(from.source)}
        %{query | from: updated_from}
      end

      # Checks the query to see if it contains a where not is_nil(deleted_at)
      # if it does, we want to be sure that we don't exclude soft deleted records
      defp has_include_deleted_at_clause?(%Ecto.Query{wheres: wheres}) do
        Enum.any?(wheres, fn %{expr: expr} ->
          expr
          |> Inspect.Algebra.to_doc(%Inspect.Opts{
            inspect_fun: fn expr, _ ->
              inspect(expr, limit: :infinity)
            end
          })
          |> String.contains?(
            "{:not, [], [{:is_nil, [], [{{:., [], [{:&, [], [0]}, :deleted_at]}, [], []}]}]}"
          )
        end)
      end
    end
  end
end
