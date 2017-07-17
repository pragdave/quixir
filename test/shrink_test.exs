defmodule ShrinkTest do

  use ExUnit.Case
  use Quixir

  setup do
    [ val: 99 ]
  end

  test "smoke" do
    assert_raise ExUnit.AssertionError, ~r/a = 50/, fn ->
      ptest a: int(min: 3, max: 100) do
        assert a < 50
      end
    end
  end

  test "minimums are being observed" do
    assert_raise ExUnit.AssertionError, ~r/a = 75/, fn ->
      ptest a: int(min: 75, max: 100) do
        assert a < 50
      end
    end
  end

  test "context is being passed in", context do
    ptest a: int(min: 3, max: 98) do
      assert context.val > a
    end
  end


  test "multiple parameters are shrunk in turn" do
    assert_raise ExUnit.AssertionError, ~r/b = 25/, fn ->
      ptest a: int(min: 3, max: 40), b: int(min: 10, max: 80) do
        assert a < 50 && b < 25
      end
    end
  end

  test "issue #12: constraints not honored when shrinking choose" do
    # Shrinking should stop at 1
    assert_raise ExUnit.AssertionError, ~r/a = 1/, fn ->
      ptest(a:  positive_int()) do
        assert a < 0
      end
    end
    
    # Shrinking should stop at 1 if the only choice is a positive int
    assert_raise ExUnit.AssertionError, ~r/b = 1/, fn ->
      ptest(b: choose( from: [ positive_int() ])) do
        assert b < 0
      end
    end
  end

end
