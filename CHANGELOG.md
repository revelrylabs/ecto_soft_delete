# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [2.0.2] - 2020-08-12

- Less strict elixir version requirement

## [2.0.1] - 2020-05-08

- Add logic to `Ecto.SoftDelete.Repo.prepare_query` to respect `where` clauses
  that explicitly include records where deleted_at is not nil

## [2.0.0] - 2020-05-06

- Exclude soft deleted records by default in `Ecto.SoftDelete.Repo`
- **BREAKING**: Make `soft_delete_fields` use `utc_datetime_usec` instead of `utc_datetime`

## [1.1.0] - 2019-02-27

### Added

- `Ecto.SoftDelete.Repo` for adding soft delete functions to repositories

## [1.0.0] - 2019-02-15

### Added

- Ecto 3 support

## [0.2.0] - 2018-12-31

### Fixed

- Missing license (MIT)

## [0.1.0] - 2017-12-20

- Initial release
