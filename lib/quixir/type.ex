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

  alias Quixir.Type.Any
  alias Quixir.Type.Int
  alias Quixir.Type.List


  defstruct type: nil, parameters: nil, must_have: nil, generator: nil, state: nil

  def next_value(type, locals) do
    type.type.next_value(type, locals)
  end

  def as_stream(type, locals) do
    Stream.unfold(type, fn type -> next_value(type, locals) end)
  end


  def any(),         do: Any.create()

  def int(),         do: Int.create()
  def int(max),      do: Int.create(max)
  def int(min, max), do: Int.create(min, max)

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


end
