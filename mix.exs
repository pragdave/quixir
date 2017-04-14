defmodule Quixir.Mixfile do
  use Mix.Project

  @version "0.9.2"

  @package [
    licenses:    ["apache 2.0"],
    maintainers: ["Dave Thomas (pragdave) <dave@pragdave.me>"],
    links:       %{
      "Github" => "https://github.com/pragdave/quixir",
    },
  ]

  @deps [
    { :pollution, "~> 0.9.1" },
    { :ex_doc,    ">= 0.0.0", only: [:dev, :test] },
  ]

  @docs [
    extras: [ "README.md" ],
    main:   "Quixir"
  ]

  @if_production  Mix.env == :prod

  @elixirc_paths (case Mix.env do
    :prod -> ["lib"]
    _     -> ["lib", "scripts"]
  end)

  @project [
    app:             :quixir,
    version:         @version,
    elixir:          "~> 1.3",
    elixirc_paths:   @elixirc_paths,
    build_embedded:  @if_production,
    start_permanent: @if_production,
    deps:            @deps,
    description:     """
    A simple property-based testing framework written in pure Elixir.
    """,
    package:         @package,
    docs:            @docs
  ]

  @application []


  # ------------------------------------------------------------

  def project,     do: @project
  def application, do: @application
end
