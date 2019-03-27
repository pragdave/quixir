# Changelog

## v0.9.4 (2019-03-27)

* Updated the way we look for a local copy of `pollution` in mix.exs.
  This will only affect you if you have a local development copy of the
  `pollution` library. If you do, and it is in a peer directory to
  quixir, then it will be used instead of the hex version.

## v0.9.1 (2016-09-08)

### Enhancements

* Add basic support for `trace:` option

### Bug fixes

* Try to remove accidental dependency on ExDoc when quixir is a dependency of
  another project.

### Documentation

* Document that shrinking is available

* Fix layout of some of the generator @doc strings that
  are imported into README.md
