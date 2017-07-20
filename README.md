Master build status: ![TravisCI Build Status](https://travis-ci.org/revelrylabs/ecto_soft_delete.svg)

# EctoSoftDelete

Adds columns, fields, and queries for soft deletion with Ecto.

## Usage

### Migrations

In migrations for schemas to support soft deletion, import `Ecto.SoftDelete.Migration`. Next, add `soft_delete_columns()` when creating a table

```elixir
defmodule MyApp.Repo.Migrations.CreateUser do
  use Ecto.Migration
  import Ecto.SoftDelete.Migration

  def change do
    create table(:users) do
      add :email, :string
      add :password, :string
      timestamps()
      soft_delete_columns()
    end
  end
end
```

### Schemas

Import `Ecto.SoftDelete.Schema` into your Schema module, then add `soft_delete_schema()` to your schema

```elixir
  defmodule User do
    use Ecto.Schema
    import Ecto.SoftDelete.Schema

    schema "users" do
      field :email,           :string
      soft_delete_schema()
    end
  end
```

### Queries

To query for items that have not been deleted, use `with_undeleted(query)` which will filter out deleted items using the `deleted_at` column produced by the previous 2 steps

```elixir
import Ecto.SoftDelete.Query

query = from(u in User, select: u)
|> with_undeleted

results = Repo.all(query)
```

## Installation

Add to mix.exs:

```elixir
defp deps do
  [{:ecto_soft_delete, "0.1.0"}]
end
```

and do

```
mix deps.get
```

## Configuration

There are currently no configuration options.

## Usage



## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/revelrylabs/ecto_soft_delete. Check out [CONTRIBUTING.md](https://github.com/revelrylabs/ecto_soft_delete/blob/master/CONTRIBUTING.md) for more info.

Everyone is welcome to participate in the project. We expect contributors to
adhere the Contributor Covenant Code of Conduct (see [CODE_OF_CONDUCT.md](https://github.com/revelrylabs/ecto_soft_delete/blob/master/CODE_OF_CONDUCT.md)).
