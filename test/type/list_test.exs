defmodule Types.ListTest do

  use ExUnit.Case

  alias  Quixir.Type
  import Type
  import Type.List

  describe "creation" do
    test "with no arguments" do
      with i = create(), constraints = i.generator_constraints do
        assert i.type == Quixir.Type.List
        assert [] in i.must_have
        assert is_integer(constraints.min_length)
        assert is_integer(constraints.max_length)
        assert constraints.min_length <= constraints.max_length
      end
    end

    test "with 1 argument" do
      with i = create(3), constraints = i.generator_constraints do
        assert i.type == Quixir.Type.List
        assert !([] in i.must_have)
        assert constraints.min_length == 3
        assert constraints.max_length == 3
      end
    end

    test "with 2 arguments" do
      with i = create(3,5), constraints = i.generator_constraints do
        assert i.type == Quixir.Type.List
        assert (![] in i.must_have)
        assert constraints.min_length == 3
        assert constraints.max_length == 5
      end
    end

    test "with 2 arguments and a minimum of 0" do
      with i = create(0,5), constraints = i.generator_constraints do
        assert i.type == Quixir.Type.List
        assert [] in i.must_have
        assert constraints.min_length == 0
        assert constraints.max_length == 5
      end
    end

    test "with a type argument" do
      with i = create(int) do
        assert i.type == Quixir.Type.List
        assert [] in i.must_have
      end
    end
  end

  describe "a generated list" do
    test "has a fixed length if so specified" do
      create(4,4)
      |> Type.as_stream([])
      |> Stream.take(5)
      |> Enum.each(fn a_list ->
          assert length(a_list) == 4
        end)
    end
    
    test "has a length between min and max" do
      min = 2
      max = 10
      create(min, max)
      |> Type.as_stream([])
      |> Enum.take(100)
      |> Enum.each(fn a_list ->
        assert length(a_list) >= min
        assert length(a_list) <= max
      end)
    end

    test "has elements of the correct type" do
      create(int)
      |> Type.as_stream([])
      |> Enum.take(5)
      |> Enum.each(fn a_list ->
        Enum.each(a_list, fn (i) -> assert is_integer(i) end)
      end)
    end

    test "has elements of the correct type with constraints" do
      create(int(2,4))
      |> Type.as_stream([])
      |> Enum.take(5)
      |> Enum.each(fn a_list ->
        Enum.each(a_list, fn (i) ->
          assert is_integer(i)
          assert i in 2..4
        end)
      end)
    end
  end
end
