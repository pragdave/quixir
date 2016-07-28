defmodule Quixir.Type.Int do

  alias Quixir.Distribution
  alias Quixir.Type

  @default_type_params %{
    type:       __MODULE__,
    generator:  Quixir.Generator.Int,
    must_have:  [ 0, -1, 1 ],
    state:      0,
    generator_constraints: %{
      distribution: Distribution.HyperNormal,
      min:      -1_000,
      max:       1_000,
    },
  }


  def create(options) when is_list(options) do

    options = Enum.into(options, %{})

    params = @default_type_params
             |> add_distribution_to_params(options)
             |> Type.add_derived_to_params(options)
             |> Type.add_min_max_to_params(options)
             |> Type.add_must_have_to_params(options)
             |> Type.trim_must_have_to_range(options)
  end


  @doc """
  Return a tuple containing the next value for this type, along with a
  potentially updated type state.

  If there are elements in the `must_have` list, return the first of them,
  and return a state where that element has been removed from `must_have`.

  Otherwise return a random value according to the generator constraints.
  """
  def next_value(type, locals) do

    type = update_with_derived_values(type, locals)

    case type[:must_have] do

      [ h | t ] ->
        { h, put_in(type.must_have, t) }

      _ ->
        val = with c = type.generator_constraints,
                do: :rand.uniform(c.max - c.min + 1) - 1 + c.min
        {val, type}
    end
  end


  def update_with_derived_values(type=%{derived: derived}, locals) when is_list(derived) do
    Enum.map(derived, fn {k,v} -> { k, v.(locals) } end)
    |> update_type_with_derived_options(type)
  end

  def update_with_derived_values(type, _) do
    type
  end


  defp update_type_with_derived_options(derived, type) do
    type
    |> Type.add_min_max_to_params(derived)
    |> Type.trim_must_have_to_range(derived)
  end

  # If the constraints are bounded, then use a uniform distribution
  # to pick between them, otherwise use a strongly center weighted one
  defp add_distribution_to_params(params, options) do
    if options[:min] && options[:max] do
      put_in(params.generator_constraints.distribution, Distribution.Uniform)
    else
      params
    end
  end


end
