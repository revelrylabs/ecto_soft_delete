defmodule Ecto.SoftDelete.Test.Repo do
  use Ecto.Repo, otp_app: :ecto_soft_delete, adapter: Ecto.Adapters.Postgres
  use Ecto.SoftDelete.Repo
end
