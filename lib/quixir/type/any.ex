defmodule Quixir.Type.Any do

  @default_type_params %{
    type:          __MODULE__,
    generator:     Quixir.Generator.Any,
    must_have:     [],
    state:         0,
    generator_constraints: %{
    },
  }

  def create() do
    @default_type_params
  end

  def next_value(type, locals) do
    {999, type}
  end

end
