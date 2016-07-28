defmodule Quixir.Type.Any do

  alias Quixir.Type

  @default_type_params %Type{
    type:          __MODULE__,
    must_have:     [],
    state:         0,
    generator_constraints: %{
    },
  }

  def create() do
    @default_type_params
  end

  def next_value(type, _locals) do
    {999, type}
  end

end
