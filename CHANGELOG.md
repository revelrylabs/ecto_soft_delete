# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2020-05-06

- Exclude soft deleted records by default in `Ecto.SoftDelete.Repo`
- **BREAKING**: Make `soft_delete_fields` use `utc_datetime_usec` instead of `utc_datetime`

## [1.1.0] - 2019-02-27

### Added

- `Ecto.SoftDelete.Repo` for adding soft delete functions to repositories.

## [1.0.0] - 2019-02-15

### Added

- Ecto 3 support

## [0.2.0]

### Fixed

- Missing license (MIT)
