defmodule Quixir.Type.Choose do

  alias Quixir.Type

  @default_type_params %{
    type:       __MODULE__,
    generator:  Quixir.Generator.Int,
    must_have:  [ ],
    state:      0,
    generator_constraints: %{
      list: []
    },
  }


  def create(list) when is_list(list) and length(list) > 0 do
    put_in(@default_type_params, [:generator_constraints, :list], list)
  end


  @doc """
  Return a tuple containing the next value for this type, along with a
  potentially updated type state.

  The next value is chosen randomly from generator_constraints.list
  """
  def next_value(type, locals) do
    list  = type.generator_constraints.list
    index = :rand.uniform(length(list)) - 1

    case Enum.at(list, index) do
      nested_type = %{ generator: _ } ->
        { val, updated_type } = Type.next_value(nested_type, locals)
        list = List.update_at(list, index, fn _ -> updated_type end)
        { val, put_in(type, [:generator_constraints, :list], list) }

      val ->
        {val, type}
    end
  end
end
