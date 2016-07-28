defmodule Quixir.Type.List do

  alias Quixir.Type

  @default_type_params %Type{
    type:         __MODULE__,
    must_have:    [],
    state:        0,
    generator_constraints: %{
      min_length:  0,
      max_length:  100,
      element_type: Type.any(),
    },
  }

  def create do
    create([])
  end

  def create(min_length, max_length)
  when is_integer(min_length) and is_integer(max_length) and min_length <= max_length do
    create(min_length: min_length, max_length: max_length)
  end

  def create(length) when is_integer(length) and length >= 0 do
    create(min_length: length, max_length: length)
  end

  def create(type) when is_map(type) do
    create(element_type: type)
  end

  def create(options = [ {_, _} | _t ]) do
    real_create(options)
  end

  def create([]) do
    real_create([])
  end

  defp real_create(options) do
    options = Enum.into(options, %{})

    @default_type_params
    |> Type.add_min_max_length_to_params(options)
    |> Type.add_must_have_to_params(options)
    |> Type.add_element_type_to_constraints(options)
    |> maybe_add_empty_list_to_must_have(options)
  end


  
  @doc """
  Return a tuple containing the next value for this type, along with a
  potentially updated type state.
  
  If there are elements in the `must_have` list, return the first of them,
  and return a state where that element has been removed from `must_have`.
  
  Otherwise return a random value according to the generator constraints.
  """
  def next_value(type, locals) do
    case type.must_have do
  
      [ h | t ] ->
        { h, %Type{type | must_have: t} }
  
      _ ->
        populate_list(type, locals)
    end
  end


  defp populate_list(type = %Type{ generator_constraints: c}, locals)
  do
    len = choose_length(c.min_length, c.max_length)
    list = c.element_type |> Type.as_stream(locals) |> Enum.take(len)
    { list, type }
  end

  defp choose_length(fixed, fixed), do: fixed
  defp choose_length(min, max) do
    trunc((max - min)*:random.uniform()) + min
  end


  defp maybe_add_empty_list_to_must_have(
        params = %{ generator_constraints: %{ min_length: 0 }, must_have: [] },
        _options
      )
  do
    Type.add_to_params(params, :must_have, [[]])
  end

  defp maybe_add_empty_list_to_must_have(params, _), do: params

end
