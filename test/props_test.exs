defmodule PropsTest do

  use ExUnit.Case
  require Quixir.Props
  import Quixir.Props, only: [props: 2, props: 3]
  import Quixir.Type

  # describe "basic expansion with" do
  # 
  #   test "no additional options" do
  #     result = quote do: (props([a: int], do: a))
  #     assert {{:., _, [_, :take]}, [], _} = Macro.expand(result, __ENV__)
  #   end
  # 
  #   test "additional options" do
  #     result = quote do: (props([a: int], try: 999, do: a))
  #     assert {{:., _, [_, :take]}, [], _} = Macro.expand(result, __ENV__)
  #   end
  # 
  #   test "two generators" do
  #     result = quote do: (props([a: int, b: int], do: {a,b}))
  #     assert {{:., _, [_, :take]}, [], _} = Macro.expand(result, __ENV__)
  #   end
  # end

  # describe "basic test" do
  #   test "that succeeds" do
  #     props([a: int, b: int(min: a, must_have: nil)], try: 3) do
  #       IO.inspect({a, b})
  #     end
  # 
  #   end
  # 
  # end

  describe "simple props smoke test" do
    test "with one type, no params" do
      code   = quote do: props([a: int], do: assert is_integer(a))
      result = Macro.expand(code, __ENV__) |> Macro.to_string
      IO.puts result
      assert result =~ ~r/%{a: int}/
      assert result =~ ~r/{a, q_tmp} = Quixir.Type.next_value\(q_state\[:a\], q_locals\)/
      assert result =~ ~r/assert\(is_integer\(a\)\)/
    end
  end

  test "run props, one type, no args" do
    props a: int do
      assert is_integer(a)
    end
  end

  test "run prop, one type, no args, explicit plist" do
    props a: int() do
      assert is_integer(a)
      IO.inspect a
    end
  end

  test "run prop, two plain types" do
    props a: int, b: list do
      assert is_integer(a)
      assert is_list(b)
    end
  end

  test "run prop, one type with options" do
    props a: int(min: 4, max: 6) do
      assert is_integer(a)
      assert a in 4..6
    end
  end

  test "run prop, two types, second depends on first" do
    props a: int, b: int(min: ^a+1, max: ^a+10) do
      IO.inspect {a, b}
      assert is_integer(a)
      assert is_integer(b)
      assert a < b
    end
  end

  test "can vary the number of runs", context do

    table = :ets.new(__MODULE__, [])

    :ets.insert(table, { :try, 0 })

    props [a: int], try: 123 do
      :ets.update_counter(table, :try, 1)
    end

    assert :ets.lookup(table, :try) == [ try: 123 ]

    :ets.delete(table)

  end
end
