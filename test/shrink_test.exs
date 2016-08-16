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

  
end
