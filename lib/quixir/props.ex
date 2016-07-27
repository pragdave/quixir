
defmodule Quixir.Props do



  @doc """
  The call

      props v1: type1, v2: type2 do
        « code to test »
      end

  sets up a property-based test. `v1` and `v2` are names of variables
  that will be set to values of types `type1` and `type2` in the block.
  The block is run multiple times with different, random-ish values for
  `v1` and `v2`.

  For example:

      props age: int(min: 0), resident: bool do
          assert PollingStation.can_vote(age, resident) == (age >= 18 && resident)
      end

  As the example shows, types can be parameterized. The parameters for a type
  may contain references to values for types that precede it in the list. In this
  case, those values must be flagged with `^`.

      props factor1: int, factor2: int(min: ^factor1, max: 2*^factor1) do
          # ...
      end
  """

  defmacro props(property_list, options \\ [], block) do
    _props(property_list, options, block)
  end
  


  defp _props(property_list, options, do: block) do

    try_count  = (options[:try] || 5)
    body = quote do
      q_state = unquote(create_generator_state(property_list))
      Enum.reduce(1..unquote(try_count), q_state, fn (_i, q_state) ->
        q_locals = %{}
        unquote_splicing(set_params(property_list))
        unquote(block)
        q_state
      end)
    end

    body
  end

  # Given
  #
  #     props age: int(min: 0), resident: bool do
  #
  # construct the map
  #
  #     %{ age: int(min: 0), resident: bool }
  #
  # We also handle pinned parameters to types
  #
  #     props factor1: int, factor2: int(min: ^factor1) do
  #
  # will generate
  #
  #     %{
  #        factor1: int,
  #        factor2: int(min: fn q_locals -> q_locals[:factor1] end)
  #      }
  #

  defp create_generator_state(property_list) do
    {
      :%{},
      [],
      property_list |> Enum.map(&create_one_state/1)
    }
  end

  defp create_one_state({name, generator}) do
    quote do
      {unquote(name), unquote(wrap_pinned_vars(generator))}
    end
  end
  
  

  # A generator can be called in the props list as
  #
  #     props a: int
  #
  # We do nothing special for this

  defp wrap_pinned_vars(code = { _, _, []}), do: code  # int()

  defp wrap_pinned_vars(code = { func, context, args})
       when is_atom(func) and is_list(context) and not is_list(args), do: code   # int

  # It can also be called with parameters. If so, the first will
  # be a keyword list. Inside that list, the values may refer
  # to the current value of a previous element in the list by
  # using the pin operator:
  #
  #     props a: int, b: int(min: ^a + 1)
  #
  # we replace the value with a function call that takes the
  # current values
  #
  #     props a: int, b: int(derived: [min: fn vals -> vals[:a] + 1 end])
  #


  defp wrap_pinned_vars({ form, context, [ params | rest ]}) do
    case Enum.reduce(params, {[], []}, &maybe_wrap/2) do

      { regular, [] } ->
        { form, context, [ regular | rest ] }

      { regular, wrapped } ->
        { form, context, [ regular ++ [ {:derived, wrapped} ] | rest ] }

    end
  end

  # `normal` is list of params that are not wrapped, and `wrapped`
  # is those that are
  defp maybe_wrap({name, value}, {normal, wrapped}) do
    if has_pins(value) do
      wrapped_param = replace_pinned_vars_with_function(value)
      { normal, [ { name, wrapped_param } | wrapped ] }
    else
      { [ { name, value } | normal ],  wrapped }
    end
  end

  defp has_pins(code) do
    Macro.prewalk(code, false, fn
      {:^, _, _}, _ -> { nil,  true }
      node, flag    -> { node, flag }
    end)
    |> elem(1)
  end

  defp replace_pinned_vars_with_function(code) do
    { updated_code, _vars } = Macro.prewalk(code, [], fn
      {:^, _, [{var, context, _}]}, acc ->
        {
          quote(do: q_locals[unquote(var)]),
          [var | acc]
        }
      node, acc ->
        {node, acc}
    end)

    quote do
      fn (q_locals) -> unquote(updated_code) end
    end
  end

  def set_params(property_list) do
    property_list |> Enum.map(&set_one_param/1)
  end

  def set_one_param({name, _generator}) do
    state_var = {name, [], nil}
    quote do
      {unquote({name, [], nil}), q_tmp} =
        Quixir.Type.next_value(q_state[unquote(name)], q_locals)
      q_locals = q_locals |> Map.put(unquote(name), unquote({name, [], nil}))
      q_state = q_state |> Map.put(unquote(name), q_tmp)
    end
  end



end
