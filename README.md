![Build Status](https://github.com/revelrylabs/ecto_soft_delete/actions/workflows/test.yml/badge.svg)
![Publish Status](https://github.com/revelrylabs/ecto_soft_delete/actions/workflows/publish.yml/badge.svg)
[![Hex.pm](https://img.shields.io/hexpm/dt/ecto_soft_delete.svg)](https://hex.pm/packages/ecto_soft_delete)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

# EctoSoftDelete

Adds columns, fields, and queries for soft deletion with Ecto.

[Documentation](https://hexdocs.pm/ecto_soft_delete)

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
      field :email, :string
      soft_delete_schema()
    end
  end
```

If you want to make sure auto-filtering is disabled for a schema, set the `auto_exclude_from_queries?` option to false

```elixir
  defmodule User do
    use Ecto.Schema
    import Ecto.SoftDelete.Schema

    schema "users" do
      field :email, :string
      soft_delete_schema(auto_exclude_from_queries?: false)
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

### Getting Deleted Rows

To query for items that have been deleted, use `with_deleted: true` 

```elixir
import Ecto.Query

query = from(u in User, select: u)

results = Repo.all(query, with_deleted: true)
```

> [!IMPORTANT]
> This only works for the topmost schema. If using `Ecto.SoftDelete.Repo`, rows fetched through associations (such as when using `Repo.preload/2`) will still be filtered.

## Repos

To support deletion in repos, just add `use Ecto.SoftDelete.Repo` to your repo.
After that, the functions `soft_delete!/1`, `soft_delete/1` and `soft_delete_all/1` will be available for you.

```elixir
# repo.ex
defmodule Repo do
  use Ecto.Repo,
    otp_app: :my_app,
    adapter: Ecto.Adapters.Postgres
  use Ecto.SoftDelete.Repo
end

# posts.ex
Repo.soft_delete_all(Post)
from(p in Post, where: p.id < 10) |> Repo.soft_delete_all()

post = Repo.get!(Post, 42)
case Repo.soft_delete post do
  {:ok, struct}       -> # Soft deleted with success
  {:error, changeset} -> # Something went wrong
end

post = Repo.get!(Post, 42)
struct = Repo.soft_delete!(post)
```

### Using Options with Soft Delete Functions
All soft delete functions support the same options as their Ecto counterparts:

```elixir
# With schema prefix for multi-tenant databases
Repo.soft_delete(post, prefix: "tenant_abc")
Repo.soft_delete!(post, prefix: "tenant_abc")
Repo.soft_delete_all(Post, prefix: "tenant_abc")
```
This allows for seamless integration with features like PostgreSQL schema prefixes for multi-tenancy.

`Ecto.SoftDelete.Repo` will also intercept all queries made with the repo and automatically add a clause to filter out soft-deleted rows.

## Installation

Add to mix.exs:

```elixir
defp deps do
  [{:ecto_soft_delete, "~> 2.0"}]
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
