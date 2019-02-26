defmodule Ecto.SoftDelete.Repo do
  @callback soft_delete_all(queryable :: Ecto.Queryable.t()) :: {integer, nil | [term]}

  defmacro __using__(_opts) do
    quote do
      def soft_delete_all(queryable) do
        update_all(queryable, set: [deleted_at: DateTime.utc_now()])
      end
    end
  end
end
