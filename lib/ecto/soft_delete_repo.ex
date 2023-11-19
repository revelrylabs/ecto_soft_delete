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
  Soft restores all entries matching the given query.

  It returns a tuple containing the number of entries and any returned
  result as second element. The second element is `nil` by default
  unless a `select` is supplied in the update query.

  ## Examples

    MyRepo.soft_restore_all(%Post{}, MyRepo)


  """
  @callback soft_restore_all(struct :: Ecto.Schema.t()) :: {integer, nil | [term]}

  @doc """
  Soft deletes a struct.
  Updates the `deleted_at` field with the current datetime in UTC.
  It returns `{:ok, struct}` if the struct has been successfully
  soft deleted or `{:error, changeset}` if there was a validation
  or a known constraint error.

  ## Examples

      post = MyRepo.get!(Post, 42)
      case MyRepo.soft_delete post do
        {:ok, struct}       -> "Soft deleted with success"
        {:error, changeset} ->  "Something went wrong"
      end

  """
  @callback soft_delete(struct_or_changeset :: Ecto.Schema.t() | Ecto.Changeset.t()) ::
              {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}

  @doc """
  Same as `c:soft_delete/1` but returns the struct or raises if the changeset is invalid.
  """
  @callback soft_delete!(struct_or_changeset :: Ecto.Schema.t() | Ecto.Changeset.t()) ::
              Ecto.Schema.t()

  @doc """
  Soft restores a struct.
  Updates the `deleted_at` to null.
  It returns `{:ok, struct}` if the struct has been successfully
  soft deleted or `{:error, changeset}` if there was a validation
  or a known constraint error.

  ## Examples

      post = MyRepo.get!(Post, 42)
      case MyRepo.soft_restore post do
        {:ok, struct}       -> "Soft restore with success"
        {:error, changeset} ->  "Something went wrong"
      end

  """
  @callback soft_restore(struct :: Ecto.Schema.t()) ::
              {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}

  @doc """
  Same as `c:soft_restore/1` but returns the struct or raises if the changeset is invalid.
  """
  @callback soft_restore!(struct :: Ecto.Schema.t()) ::
              Ecto.Schema.t()

  defmacro __using__(_opts) do
    quote do
      import Ecto.Query

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

      def soft_restore_all(struct, repo \\ :context) do
        source = Ecto.get_meta(struct, :source)

        context =
          case repo do
            :context -> Ecto.get_meta(struct, :context)
            _ -> repo
          end

        %{
          columns: _,
          command: _,
          connection_id: _,
          messages: _,
          num_rows: num_rows,
          rows: rows
        } =
          Ecto.Adapters.SQL.query!(
            context,
            "UPDATE #{source} SET deleted_at = NULL"
          )

        {num_rows, rows}
      end

      def soft_restore(struct, key \\ "id", repo \\ nil) do
        value =
          Map.from_struct(struct)
          |> Map.get(String.to_atom(key))

        source = Ecto.get_meta(struct, :source)

        context =
          case repo do
            nil -> Ecto.get_meta(struct, :context)
            _ -> repo
          end

        %{
          columns: _,
          command: _,
          connection_id: _,
          messages: _,
          num_rows: num_rows,
          rows: rows
        } =
          Ecto.Adapters.SQL.query!(
            context,
            "UPDATE #{source} SET deleted_at = NULL WHERE #{key} = $1",
            [value]
          )

        {num_rows, rows}
      end

      @doc """
      Overrides all query operations to exclude soft deleted records
      if the schema in the from clause has a deleted_at column
      NOTE: will not exclude soft deleted records if :with_deleted option passed as true
      """
      def prepare_query(_operation, query, opts) do
        schema_module = get_schema_module_from_query(query)
        fields = if schema_module, do: schema_module.__schema__(:fields), else: []
        soft_deletable? = Enum.member?(fields, :deleted_at)

        if has_include_deleted_at_clause?(query) || opts[:with_deleted] || !soft_deletable? do
          {query, opts}
        else
          query = from(x in query, where: is_nil(x.deleted_at))
          {query, opts}
        end
      end

      # Checks the query to see if it contains a where not is_nil(deleted_at)
      # if it does, we want to be sure that we don't exclude soft deleted records
      defp has_include_deleted_at_clause?(%Ecto.Query{wheres: wheres}) do
        Enum.any?(wheres, fn %{expr: expr} ->
          expr == {:not, [], [{:is_nil, [], [{{:., [], [{:&, [], [0]}, :deleted_at]}, [], []}]}]}
        end)
      end

      defp get_schema_module_from_query(%Ecto.Query{from: %{source: {_name, module}}}) do
        module
      end

      defp get_schema_module_from_query(_), do: nil
    end
  end
end
