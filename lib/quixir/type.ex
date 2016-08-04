defmodule Quixir.Type do

  @types_in_any [
    Quixir.Type.Choose,
    Quixir.Type.Float,
    Quixir.Type.Int,
    Quixir.Type.List,
    Quixir.Type.String,
    Quixir.Type.Tuple,
  ]

  @all_types [ Quixir.Type.Any | @types_in_any ]

  # for i <- @all_types do
  #   Code.eval_quoted(quote do
  #                     alias unquote(i)
  #   end)
  # end

  alias Quixir.Type.{Any, Choose, Float, Int, List, String, Tuple}


  defstruct(
    type:                  __MODULE__,
    must_have:             [ ],
    state:                 nil,
    generator_constraints: %{ }
  )

  def next_value(type, locals) do
    type.type.next_value(type, locals)
  end

  def as_stream(type, locals) do
    Stream.unfold(type, fn type -> next_value(type, locals) end)
  end


  #######
  # any #
  #######

  def any(), do: Choose.create(from: @types_in_any)


  ########
  # bool #
  ########

  def bool() do
    Choose.create(from: [ false, true ])
  end
  
  ##########
  # choose #
  ##########

  def choose(from) when is_list(from) do
    Choose.create(from: from)
  end

  #########
  # float #
  ##Q######

  def float() do
    Float.create([])
  end

  def float(min, max)
  when (is_number(min) or is_function(min)) and (is_number(max) or is_function(max)) do
    Float.create(min: min, max: max)
  end

  def float(max) when is_number(max) or is_function(max) do
    Float.create(min: 1.0, max: max)
  end

  def float(options) when is_list(options) do
    Float.create(options)
  end

  def positive_float do
    Float.create(min: Float.epsilon)
  end

  def negative_float do
    Float.create(max: -Float.epsilon)
  end

  def nonnegative_float do
    Float.create(min: 0.0)
  end

  #######
  # int #
  #######

  def int() do
    Int.create([])
  end

  def int(min, max)
  when (is_integer(min) or is_function(min)) and (is_integer(max) or is_function(max)) do
    Int.create(min: min, max: max)
  end

  def int(max) when is_integer(max) or is_function(max) do
    Int.create(min: 1, max: max)
  end

  def int(options) when is_list(options) do
    Int.create(options)
  end

  def positive_int do
    Int.create(min: 1)
  end

  def negative_int do
    Int.create(max: -1)
  end

  def nonnegative_int do
    Int.create(min: 0)
  end

  ########
  # list #
  ########

  def list(),                       do: List.create()
  def list(max_length),             do: List.create(max_length)
  def list(min_length, max_length), do: List.create(min_length, max_length)
  

  ##########
  # string #
  ##########

  def string(),     do: string([])
  def string(opts), do: String.create(opts)

  #########
  # tuple #
  #########

  def tuple(),                       do: Tuple.create([])
  def tuple(min_length, max_length) when is_integer(min_length) and is_integer(max_length) do
    Tuple.create(min_length: min_length, max_length: max_length)
  end
  def tuple(max_length) when is_integer(max_length) do
    Tuple.create(max_length: max_length)
  end
  def tuple(options = [ {_, _} | _ ]) do
    Tuple.create(options)
  end

  #########################
  # Helpers used by types #
  #########################

  def add_derived_to_params(params, options) do
    params
    |> add_to_params(:derived, options[:derived])
  end

  def add_min_max_to_params(params, options) do
    params
    |> add_to_constraints(:min, options[:min])
    |> add_to_constraints(:max, options[:max])
  end

  def add_min_max_length_to_params(params, options) do
    params
    |> add_to_constraints(:min_length, options[:min_length])
    |> add_to_constraints(:max_length, options[:max_length])
  end

  def add_must_have_to_params(params, options) do
    add_to_params(params, :must_have, options[:must_have])
  end

  def add_element_type_to_constraints(params, options) do
    add_to_constraints(params, :element_type, options[:element_type])
  end


  def add_to_params(params, _keys, nil),  do: params
  def add_to_params(params, key, value) when is_atom(key) do
    Map.put(params, key, value)
  end

  def add_to_constraints(params, _key, nil), do: params
  def add_to_constraints(params, key, value) when is_atom(key) do
    constraints = params.generator_constraints
    constraints = Map.put(constraints, key, value)
    %{ params | generator_constraints: constraints }
  end


  def trim_must_have_to_range(params, _options) do
    min = params.generator_constraints.min
    max = params.generator_constraints.max
    updated_must_have =
      params.must_have
      |> Enum.filter(fn val -> val >= min && val <= max end)
    Map.put(params, :must_have, updated_must_have)
  end


end
