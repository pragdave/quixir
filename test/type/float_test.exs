defmodule Type.FloatTest do

  use     ExUnit.Case
  require Quixir.Props
  import  Quixir.Props, only: [props: 2]

  alias  Quixir.Type
  alias  Type.Float

  import Type, only: [
    float: 0, float: 1, float: 2,
    positive_float:    0,
    negative_float:    0,
    nonnegative_float: 0
  ]


  describe "creation" do
    test "with no arguments" do
      with f = float, constraints = f.generator_constraints do
        assert f.type == Float
  
        assert  0.0 in f.must_have
        assert -1.0 in f.must_have
        assert  1.0 in f.must_have
  
        assert Float.epsilon  in f.must_have
        assert -Float.epsilon in f.must_have
  
        assert length(f.must_have) == 5
  
        assert is_float(constraints.min)
        assert is_float(constraints.max)
  
        assert constraints.min < constraints.max
      end
    end
  
    test "with 1 argument" do
      with f = float(99.5), constraints = f.generator_constraints do
        assert constraints.max == 99.5
        assert constraints.min == 1.0
      end
    end
    
    test "with two arguments" do
      with f = float(4.25, 6.5), constraints = f.generator_constraints do
        assert constraints.max == 6.5
        assert constraints.min == 4.25
      end
    end
    
    test "with keyword arguments" do
      with f = float(min: 3.125, max: 20.0), constraints = f.generator_constraints do
        assert constraints.max == 20.0
        assert constraints.min == 3.125
        assert f.must_have == []
      end
    end
    
    test "truncates must_have to range" do
      with f = float(min: 1, max: 20), constraints = f.generator_constraints do
        assert constraints.max == 20
        assert constraints.min == 1
        assert f.must_have == [ 1.0 ]
      end
    end
    
    test "with keyword arguments including type level constraints" do
      with f = float(min: 3.0, max: 20.0, must_have: [4.5, 5.25, 6.125]),
           constraints = f.generator_constraints do
        assert constraints.max == 20.0
        assert constraints.min == 3.0
        assert f.must_have == [4.5, 5.25, 6.125]
      end
    end
  end

  # describe "distribution is" do
  # 
  #   alias Quixir.Distribution.{HyperNormal, Uniform}
  # 
  #   test "HyperNormal if min missing" do
  #     with i = int(max: 20), constraints = i.generator_constraints do
  #       assert constraints[:distribution] == HyperNormal
  #     end
  #   end
  # 
  #   test "HyperNormal if max missing" do
  #     with i = int(min: 20), constraints = i.generator_constraints do
  #       assert constraints[:distribution] == HyperNormal
  #     end
  #   end
  # 
  #   test "Uniform if min and max given" do
  #     with i = int(min: 20, max: 30), constraints = i.generator_constraints do
  #       assert constraints[:distribution] == Uniform
  #     end
  #   end
  # 
  # end
  # 
  describe "shortcuts" do
  
    test "float()" do
      props val: float do
        assert is_float(val)
      end
    end
  
    test "float(max)" do
      props val: float(10.0) do
        assert is_float(val)
        assert val >= 1.0
        assert val <= 10.0
      end
    end
  
    test "float(min, max)" do
      props val: float(5, 10) do
        assert is_float(val)
        assert val >= 5
        assert val <= 10
      end
    end
    
    test "positive_float" do
      props val: positive_float do
        assert is_float(val)
        assert val > 0.0
      end
    end
    
    test "negative_float" do
      props val: negative_float do
        assert is_float(val)
        assert val < 0
      end
    end
  
    test "nonnegative_float" do
      props val: nonnegative_float do
        assert is_float(val)
        assert val >= 0.0
      end
    end
  
  end

  describe "values returned" do
    test "include must_have values" do
      f = float(must_have: [5.0, 5.5, 9.25])
      assert f |> Type.as_stream([]) |> Enum.take(3) == [5.0, 5.5, 9.25]
    end
  end
  
  describe "Uniform distribution" do
    test "has a mean around the middle" do
      f = float(min: 20, max: 40)
      assert f.generator_constraints.distribution == Quixir.Distribution.Uniform
  
      numbers = f |> Type.as_stream([]) |> Enum.take(100)
      mean = Enum.sum(numbers) / length(numbers)
      assert abs(mean - 30.0) < 2
    end
  end


end
