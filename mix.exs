defmodule Quixir.Mixfile do
  use Mix.Project

  @version "0.1.0"

  @package [
    licenses:    ["apache 2.0"],
    maintainers: ["Dave Thomas (pragdave) <dave@pragdave.me>"],
    links:       %{
      "Github" => "https://github.com/pragdave/quixir",
    },
  ]
  
  @deps [
    { :pollution, git: "git://github.com/pragdave/pollution.git" },
    { :ex_doc,         ">= 0.0.0", only: :dev },
  ]

  @if_production  Mix.env == :prod

  @docs [
    extras: [ "README.md" ],
    main:   "Quixir"
  ]
  
  @project [
    app:             :quixir,
    version:         @version,
    elixir:          "~> 1.3",
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
