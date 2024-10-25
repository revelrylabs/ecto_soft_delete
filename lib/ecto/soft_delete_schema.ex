defmodule Ecto.SoftDelete.Schema do
  @moduledoc """
  Contains schema macros to add soft delete fields to a schema
  """

  @doc """
  Adds the deleted_at column to a schema

      defmodule User do
        use Ecto.Schema
        import Ecto.SoftDelete.Schema

        schema "users" do
          field :email,           :string
          soft_delete_schema()
        end
      end

  Options:
  - `:skip_prepare_query?` - If true, Ecto.SoftDelete.Repo won't automatically
  add the necessary clause to filter aout soft-deleted rows. See
  `Ecto.SoftDelete.Repo.prepare_query` for more info. Defaults to `false`.

  """
  defmacro soft_delete_schema(opts \\ []) do
    filter_tag_definition =
      if Keyword.get(opts, :skip_prepare_query?, false) do
        quote do
          def skip_soft_delete_prepare_query?, do: true
        end
      end

    quote do
      field :deleted_at, :utc_datetime_usec
      unquote(filter_tag_definition)
    end
  end
end
