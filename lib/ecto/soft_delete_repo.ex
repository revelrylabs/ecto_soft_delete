defmodule Ecto.SoftDelete.Repo do
  @callback soft_delete_all(queryable :: Ecto.Queryable.t()) :: {integer, nil | [term]}
  @callback soft_delete(struct_or_changeset :: Ecto.Schema.t() | Ecto.Changeset.t()) :: {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}

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

      defp utc_now do
        DateTime.truncate(DateTime.utc_now(), :second)
      end
    end
  end
end
