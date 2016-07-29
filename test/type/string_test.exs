defmodule Types.StringTest do

  use ExUnit.Case

  alias  Quixir.Type
  import Type
  import Quixir.Props, only: [ props: 2 ]


  test "string() returns strings of utf characters" do
    props str: string do
      assert is_binary(str)
      assert String.valid?(str)
    end
  end

  test "string() returns ascii if requested" do
    props str: string(chars: :ascii) do
      assert is_binary(str)
      assert String.valid?(str)
      String.to_charlist(str)
      |> Enum.each(fn (ch) -> assert ch in 0..127 end)
    end
  end

  test "string() returns digits if requested" do
    props str: string(chars: :digit) do
      assert is_binary(str)
      assert String.valid?(str)
      String.to_charlist(str)
      |> Enum.each(fn (ch) -> assert ch in ?0..?9 end)
    end
  end

  test "string() returns lowercase if requested" do
    props str: string(chars: :lower) do
      assert is_binary(str)
      assert String.valid?(str)
      String.to_charlist(str)
      |> Enum.each(fn (ch) -> assert ch in ?a..?z end)
    end
  end

  test "string() returns uppercase if requested" do
    props str: string(chars: :upper) do
      assert is_binary(str)
      assert String.valid?(str)
      String.to_charlist(str)
      |> Enum.each(fn (ch) -> assert ch in ?A..?Z end)
    end
  end

  test "string() returns a range if requested" do
    props str: string(chars: ?e..?m) do
      assert is_binary(str)
      assert String.valid?(str)
      String.to_charlist(str)
      |> Enum.each(fn (ch) -> assert ch in ?e..?m end)
    end
  end

  



  describe "must_have" do
    test "for unbounded string returns an empty string and a space" do
      strings = string |> Type.as_stream([]) |> Enum.take(2)
      assert "" in strings
      assert " " in strings
    end

    test "for string(min_length: 1) returns a space" do
      strings = string(min_length: 1) |> Type.as_stream([]) |> Enum.take(1)
      assert " " in strings
    end

    test "for string(max_length: 0) returns empty string" do
      strings = string(max_length: 0) |> Type.as_stream([]) |> Enum.take(3)
      assert strings == [ "", "", "" ]
    end
    
  end
end
