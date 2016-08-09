defmodule ShrinkTest do

  use ExUnit.Case
  use Quixir

  test "smoke" do
    ptest a: int(min: 3, max: 10) do
      assert a != 5
    end
  end
end
