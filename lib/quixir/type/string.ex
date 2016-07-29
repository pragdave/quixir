defmodule Quixir.Type.String do

  alias Quixir.Type

  @default_type_params %Type{
    type:       __MODULE__,
    must_have:  [ "", " " ],
    state:      0,
    generator_constraints: %{
      min_length: 0,
      max_length: 300,
      char_range: 0..0xd7af
    },
  }


  def create(options) do
    @default_type_params
    |> add_character_generator_to_params(options)
    |> Type.add_min_max_length_to_params(options)
    |> trim_must_have_to_range
  end


  defp add_character_generator_to_params(params, options) do
    with {remove_must_have, range} = character_range_for(options[:chars]) do
      if remove_must_have do
        Type.add_to_params(params, :must_have, [])
      else
        params
      end
      |> Type.add_to_constraints(:char_range, range)
    end
  end

  defp character_range_for(nil),        do: {false, 0..0xd7af}
  defp character_range_for(:ascii),     do: {false, 0..127}
  defp character_range_for(:printable), do: {true, 32..126}
  defp character_range_for(:digits),    do: {true, ?0..?9}
  defp character_range_for(:upper),     do: {true, ?A..?Z}
  defp character_range_for(:lower),     do: {true, ?a..?z}
  defp character_range_for(%Range{} = range) do
    {true, range}
  end
  defp character_range_for(:digit) do
    character_range_for(:digits)
  end


  defp trim_must_have_to_range(params) do
    c = params.generator_constraints
    min = c.min_length
    max = c.max_length

    must_have = Enum.filter(params.must_have, fn str ->
      String.length(str) in min..max
    end)

    Type.add_to_params(params, :must_have, must_have)
  end

  @doc """
  Return a tuple containing the next value for this type, along with a
  potentially updated type state.

  The next value is chosen randomly from generator_constraints.list
  """
  def next_value(type, locals) do

#    type = update_with_derived_values(type, locals)

    case type.must_have do

      [ h | t ] ->
        { h, %Type{type | must_have: t} }

      _ ->
        with c = type.generator_constraints,
             len = :rand.uniform(c.max_length - c.min_length + 1) - 1 + c.min_length do

           val = generate_chars(type, len)
           {val, type}
         end
    end
  end

  defp generate_chars(_, 0), do: ""
  defp generate_chars(type, len) do
    range = type.generator_constraints.char_range
    char_generator = fn n ->
      :rand.uniform(range.last - range.first + 1) + range.first - 1
    end
    Enum.map(1..len, char_generator) |> List.to_string
  end

end
