defmodule Type.IntTest do

  use     ExUnit.Case
  require Quixir.Props
  import  Quixir.Props, only: [props: 2]

  alias  Quixir.Type
  import Type, only: [int: 0, int: 1, int: 2,
                      positive_int:    0,
                      negative_int:    0,
                      nonnegative_int: 0 ]

  describe "creation" do
    test "with no arguments" do
      with i = int, constraints = i.generator_constraints do
        assert i.type == Quixir.Type.Int
        assert  0 in i.must_have
        assert -1 in i.must_have
        assert  1 in i.must_have

        assert is_integer(constraints.min)
        assert is_integer(constraints.max)

        assert constraints.min < constraints.max
      end
    end

    test "with 1 argument" do
      with i = int(99), constraints = i.generator_constraints do
        assert constraints.max == 99
        assert constraints.min == 1
      end
    end

    test "with two integer arguments" do
      with i = int(4, 6), constraints = i.generator_constraints do
        assert constraints.max == 6
        assert constraints.min == 4
      end
    end

    test "with keyword arguments" do
      with i = int(min: 3, max: 20), constraints = i.generator_constraints do
        assert constraints.max == 20
        assert constraints.min == 3
        assert i.must_have == []
      end
    end

    test "truncates must_have to range" do
      with i = int(min: 1, max: 20), constraints = i.generator_constraints do
        assert constraints.max == 20
        assert constraints.min == 1
        assert i.must_have == [ 1 ]
      end
    end
    
    test "with keyword arguments including type level constraints" do
      with i = int(min: 3, max: 20, must_have: [4,5,6]),
           constraints = i.generator_constraints do
        assert constraints.max == 20
        assert constraints.min == 3
        assert i.must_have == [4, 5, 6]
      end
    end
  end

  describe "distribution is" do

    alias Quixir.Distribution.{HyperNormal, Uniform}

    test "HyperNormal if min missing" do
      with i = int(max: 20), constraints = i.generator_constraints do
        assert constraints[:distribution] == HyperNormal
      end
    end

    test "HyperNormal if max missing" do
      with i = int(min: 20), constraints = i.generator_constraints do
        assert constraints[:distribution] == HyperNormal
      end
    end

    test "Uniform if min and max given" do
      with i = int(min: 20, max: 30), constraints = i.generator_constraints do
        assert constraints[:distribution] == Uniform
      end
    end

  end

  describe "shortcuts" do

    test "int()" do
      props val: int do
        assert is_integer(val)
      end
    end

    test "int(max)" do
      props val: int(10) do
        assert is_integer(val)
        assert val in 1..10
      end
    end

    test "int(min, max)" do
      props val: int(5, 10) do
        assert is_integer(val)
        assert val in 5..10
      end
    end

    test "positive_int" do
      props val: positive_int do
        assert val > 0
      end
    end

    test "negative_int" do
      props val: negative_int do
        assert val < 0
      end
    end

    test "nonnegative_int" do
      props val: nonnegative_int do
        assert val >= 0
      end
    end
  end

  describe "values returned" do
    test "include must_have values" do
      i = int(must_have: [5, 7, 9])

      assert i |> Type.as_stream([]) |> Enum.take(3) == [ 5, 7, 9 ]
    end
  end

  describe "Uniform distribution" do

    test "has a mean around the middle" do
      i = int(min: 20, max: 40)
      assert i.generator_constraints.distribution == Quixir.Distribution.Uniform

      numbers = i |> Type.as_stream([]) |> Enum.take(100)
      mean = Enum.sum(numbers) / length(numbers)
      assert abs(mean - 30) < 2
    end
  end

  # describe "HyperNormal distribution" do
  #   setup do
  #     i = create()
  #     assert i.constraints[:distribution] == Quixir.Distribution.HyperNormal
  # 
  #     [ numbers: Enum.map(1..100, fn (_) -> IO.inspect(sample(i)) end) ]
  #   end
  # 
  #   test "has a mean around zero", context do
  # 
  #     with nums = context.numbers,
  #          mean = Enum.reduce(nums, &+/2) / length(nums) do
  # 
  #       assert abs(mean) < 10
  # 
  #     end
  #   end
  # end


end
