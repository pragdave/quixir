defmodule Quixir.Type do

  @types_in_any [
    Quixir.Type.Int,
    Quixir.Type.List
  ]

  @all_types [ Quixir.Type.Any | @types_in_any ]

  # for i <- @all_types do
  #   Code.eval_quoted(quote do
  #                     alias unquote(i)
  #   end)
  # end

  alias Quixir.Type.{Any, Float, Int, List}

  defstruct type: nil, parameters: nil, must_have: nil, generator: nil, state: nil

  def next_value(type, locals) do
    type.type.next_value(type, locals)
  end

  def as_stream(type, locals) do
    Stream.unfold(type, fn type -> next_value(type, locals) end)
  end


  #######
  # any #
  #######

  def any(), do: Any.create()

  #######
  # int #
  #######

  def int() do
    Int.create([])
  end

  def int(min, max) when is_integer(min) and is_integer(max) do
    Int.create(min: min, max: max)
  end

  def int(max) when is_integer(max) do
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

  #######
  # float #
  #######

  def float() do
    Float.create([])
  end

  def float(min, max) when is_number(min) and is_number(max) do
    Float.create(min: min, max: max)
  end

  def float(max) when is_number(max) do
    Float.create(min: 1, max: max)
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

  ########
  # list #
  ########

  def list(),                       do: List.create()
  def list(max_length),             do: List.create(max_length)
  def list(min_length, max_length), do: List.create(min_length, max_length)
  



  #########################
  # Helpers used by types #
  #########################

  def add_derived_to_params(params, options) do
    params
    |> add_to_params([:derived], options[:derived])
  end

  def add_min_max_to_params(params, options) do
    params
    |> add_to_params([:generator_constraints, :min], options[:min])
    |> add_to_params([:generator_constraints, :max], options[:max])
  end

  def add_min_max_length_to_params(params, options) do
    params
    |> add_to_params([:generator_constraints, :min_length], options[:min_length])
    |> add_to_params([:generator_constraints, :max_length], options[:max_length])
  end

  def add_must_have_to_params(params, options) do
    add_to_params(params, [:must_have], options[:must_have])
  end

  def add_element_type_to_params(params, options) do
    add_to_params(params, [:element_type], options[:element_type])
  end


  def add_to_params(params, _keys, nil),  do: params
  def add_to_params(params, keys, value), do: put_in(params, keys, value)


  def trim_must_have_to_range(params, _options) do
    min = params.generator_constraints.min
    max = params.generator_constraints.max
    updated_must_have =
      params.must_have
      |> Enum.filter(fn val -> val >= min && val <= max end)
    put_in(params, [:must_have], updated_must_have)
  end

  
end
