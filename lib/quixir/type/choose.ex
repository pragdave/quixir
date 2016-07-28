defmodule Quixir.Type.Choose do

  alias Quixir.Type

  @default_type_params %{
    type:       __MODULE__,
    generator:  Quixir.Generator.Int,
    must_have:  [ ],
    state:      0,
    generator_constraints: %{
      from: []
    },
  }


  def create(from: from ) do
    Type.add_to_constraints(@default_type_params, :from, from)
  end


  @doc """
  Return a tuple containing the next value for this type, along with a
  potentially updated type state.

  The next value is chosen randomly from generator_constraints.list
  """
  def next_value(type, locals) do
    from  = type.generator_constraints.from
    index = :rand.uniform(length(from)) - 1

    case Enum.at(from, index) do
      nested_type = %{__struct__: Quixir.Type} ->
        { val, updated_type } = Type.next_value(nested_type, locals)
        from = List.update_at(from, index, fn _ -> updated_type end)
        { val, Type.add_to_constraints(type, :from, from) }

      val ->
        { val, type }
    end
  end
end
