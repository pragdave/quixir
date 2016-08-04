defmodule Quixir.Mixfile do
  use Mix.Project

  @version "0.1.0"

  @deps [
    pollution: "~> 0.0"
  ]

  @project [
    app:             :quixir,
    version:         @version,
    elixir:          "~> 1.3",
    build_embedded:  Mix.env == :prod,
    start_permanent: Mix.env == :prod,
    deps:            @deps
  ]

  @application []


  # ------------------------------------------------------------

  def project,     do: @project
  def application, do: @application
end
