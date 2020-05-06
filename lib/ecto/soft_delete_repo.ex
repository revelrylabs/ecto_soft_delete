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
  @callback soft_delete(struct_or_changeset :: Ecto.Schema.t() | Ecto.Changeset.t()) :: {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}

  @doc """
  Same as `c:soft_delete/1` but returns the struct or raises if the changeset is invalid.
  """
  @callback soft_delete!(struct_or_changeset :: Ecto.Schema.t() | Ecto.Changeset.t()) :: Ecto.Schema.t()

  defmacro __using__(_opts) do
    quote do
      def soft_delete_all(queryable) do
        update_all(queryable, set: [deleted_at: utc_now()])
      end

      def soft_delete(struct_or_changeset) do
        struct_or_changeset
        |> Ecto.Changeset.change(deleted_at: utc_now())
        |> update()
      end

      def soft_delete!(struct_or_changeset) do
        struct_or_changeset
        |> Ecto.Changeset.change(deleted_at: utc_now())
        |> update!()
      end

      defp utc_now do
        DateTime.truncate(DateTime.utc_now(), :second)
      end

      def all(queryable, opts) do

      end

      def all_undeleted(queryable, opts) do
        queryable

        |> Ecto.Repo.all()
      end

      @doc """
      Overrides all query operations to exclude soft deleted records
      if the schema in the from clause has a deleted_at column
      NOTE: will not exclude soft deleted records if :with_deleted option passed as true
      """
      def prepare_query(_operation, query, opts) do
        %{from: %{source: {_name, module}}} = Map.from_struct(query)

        fields = module.__schema__(:fields)
        soft_deletable? = Enum.member?(fields, :deleted_at)

        if opts[:with_deleted] || !soft_deletable? do
          {query, opts}
        else
          query = from(x in query, where: is_nil(x.deleted_at))
          {query, opts}
        end
      end
    end
  end
end
