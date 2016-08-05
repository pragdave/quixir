defmodule PropsTest do

  use ExUnit.Case
  use Quixir


  describe "simple ptest smoke test" do
    test "with one type, no params" do
      code   = quote do: ptest([a: int], do: assert is_integer(a))
      result = Macro.expand(code, __ENV__) |> Macro.to_string
      assert result =~ ~r/%{a: int}/
      assert result =~ ~r/{a, q_tmp} = .*\.next_value\(q_state\[:a\], q_locals\)/
      assert result =~ ~r/assert\(is_integer\(a\)\)/
    end
  end

  test "one type, no args" do
    ptest a: int do
      assert is_integer(a)
    end
  end
  
  test "one type, no args, explicit plist" do
    ptest a: int() do
      assert is_integer(a)
    end
  end
  
  test "two plain types" do
    ptest a: int, b: list do
      assert is_integer(a)
      assert is_list(b)
    end
  end
  
  test "one type with options" do
    ptest a: int(min: 4, max: 6) do
      assert is_integer(a)
      assert a in 4..6
    end
  end
  
  test "two types, second depends on first" do
    ptest a: int, b: int(min: ^a+1, max: ^a+10) do
      assert is_integer(a)
      assert is_integer(b)
      assert a < b
    end
  end
  

  test "runs 100 times by default" do
    table = :ets.new(__MODULE__, [])
    :ets.insert(table, { :repeat_for, 0 })
  
    ptest [a: int] do
      :ets.update_counter(table, :repeat_for, 1)
    end
  
    assert :ets.lookup(table, :repeat_for) == [ repeat_for: 100 ]
    :ets.delete(table)
  end
  
  test "can vary the number of runs" do
    table = :ets.new(__MODULE__, [])
    :ets.insert(table, { :repeat_for, 0 })
  
    ptest [a: int], repeat_for: 123 do
      :ets.update_counter(table, :repeat_for, 1)
    end
  
    assert :ets.lookup(table, :repeat_for) == [ repeat_for: 123 ]
    :ets.delete(table)
  end

end
