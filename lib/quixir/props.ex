
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

    try_count  = (options[:repeat_for] || 100)

    body = quote do
      q_state = unquote(create_generator_state(property_list))
      Enum.reduce(1..unquote(try_count), q_state, fn (_i, q_state) ->
        q_locals = %{}
        unquote_splicing(set_params(property_list))
        unquote(block)
        q_state
      end)
    end

    #    body |> Macro.to_string |> IO.puts
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
      { unquote(name), unquote(wrap_pinned_vars(generator)) }
    end
  end


  # A generator can be called in the props list as
  #
  #     props a: int
  #
  # We do nothing special for this
  #
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


  defp wrap_pinned_vars({gen, context, [ args = [ { _, _ } | _ ] | rest ]}) do
    { regular, derived } = wrap_each(args)

    final_args = if length(derived) > 0 do
      regular ++ [ derived: derived ]
    else
      regular
    end

    {
      gen,
      context,
      [ final_args | rest ]
    }
  end

  defp wrap_pinned_vars(other), do: other

  defp wrap_each(args) do
    Enum.reduce(args, { [], [] }, &wrap_one_arg/2)
  end

  defp wrap_one_arg({name, value}, { regular, derived }) do
    if has_pinned_vars?(value) do
      new_value = quote do
        fn q_locals ->
          unquote(Macro.prewalk(value, [], &pin_subexpr/2) |> elem(0))
        end
      end
      {
        regular,
        [ { name, new_value } | derived ]
      }
    else
      {
        [ { name, value } | regular ],
        derived
      }
    end
  end

  def pin_subexpr({:^, _meta, [{var, _, _}]},  acc) do
    { quote(do: q_locals[unquote(var)]), acc }
  end
  
  def pin_subexpr(arg,  acc) do
    { arg, acc }
  end

  def has_pinned_vars?(expr) do
    Macro.prewalk(expr, false, fn
      {:^, _, _}, _acc -> { :ok, true }
      node, acc        -> { node, acc }
    end)
    |> elem(1)
  end

  def set_params(property_list) do
    property_list |> Enum.map(&set_one_param/1)
  end

  def set_one_param({name, _generator}) do
    quote do
      {unquote({name, [], nil}), q_tmp} =
        Quixir.Type.next_value(q_state[unquote(name)], q_locals)
      q_locals = q_locals |> Map.put(unquote(name), unquote({name, [], nil}))
      q_state = q_state |> Map.put(unquote(name), q_tmp)
    end
  end



end
