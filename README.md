# EctoSoftDelete

[![Build Status](https://travis-ci.org/revelrylabs/ecto_soft_delete.svg?branch=master)](https://travis-ci.org/revelrylabs/ecto_soft_delete)
[![Coverage Status](https://opencov.prod.revelry.net/projects/21/badge.svg)](https://opencov.prod.revelry.net/projects/21)
[![Module Version](https://img.shields.io/hexpm/v/ecto_soft_delete.svg)](https://hex.pm/packages/ecto_soft_delete)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/ecto_soft_delete/)
[![Total Download](https://img.shields.io/hexpm/dt/ecto_soft_delete.svg)](https://hex.pm/packages/ecto_soft_delete)
[![License](https://img.shields.io/hexpm/l/ecto_soft_delete.svg)](https://github.com/revelrylabs/ecto_soft_delete/blob/master/LICENSE)
[![Last Updated](https://img.shields.io/github/last-commit/revelrylabs/ecto_soft_delete.svg)](https://github.com/revelrylabs/ecto_soft_delete/commits/master)

Adds columns, fields, and queries for soft deletion with Ecto.

## Installation

The package can be installed by adding `:ecto_soft_delete` to your list of
dependencies in `mix.exs`:

Add to mix.exs:

```elixir
defp deps do
  [
    {:ecto_soft_delete, "~> 1.0"}
  ]
end
```

and do:

```
mix deps.get
```

## Usage

### Migrations

In migrations for schemas to support soft deletion, import
`Ecto.SoftDelete.Migration`. Next, add `soft_delete_columns()` when creating a
table:

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

Import `Ecto.SoftDelete.Schema` into your Schema module, then add
`soft_delete_schema()` to your schema:

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

To query for items that have not been deleted, use `with_undeleted(query)`
which will filter out deleted items using the `deleted_at` column produced by
the previous 2 steps:

```elixir
import Ecto.SoftDelete.Query

query = from(u in User, select: u)
|> with_undeleted

results = Repo.all(query)
```

### Repos

To support deletion in repos, just add `use Ecto.SoftDelete.Repo` to your repo.

After that, the functions `soft_delete!/1`, `soft_delete/1` and
`soft_delete_all/1` will be available for you.

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

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/revelrylabs/ecto_soft_delete. Check out
[CONTRIBUTING.md](./CONTRIBUTING.md) for more info.

Everyone is welcome to participate in the project. We expect contributors to
adhere the Contributor Covenant Code of Conduct (see [CODE_OF_CONDUCT.md](./CODE_OF_CONDUCT.md)).

## Copyright and License

Copyright (c) 2018 Revelry Labs LLC

This library is released under the MIT License. See the [LICENSE.md](./LICENSE.md) file
for further details.
