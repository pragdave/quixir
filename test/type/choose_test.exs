defmodule Types.ChooseTest do

  use ExUnit.Case

  alias  Quixir.Type
  import Type
  import Type.Choose


  describe "a choice of literals" do
    test "returns them reasonably distributed" do
      counts = create([:a, "cat", 99])
      |> Type.as_stream([])
      |> Stream.take(100)
      |> Enum.reduce(%{ :a => 0, "cat" => 0, 99 => 0}, fn (val, counts) ->
           assert val in [:a, "cat", 99]
           Map.put(counts, val, counts[val]+1);
      end)

      with likely_range = 20..45 do
        assert counts[:a]    in likely_range
        assert counts["cat"] in likely_range
        assert counts[99]    in likely_range
      end
    end
  end

  describe "a mixture of literals and generators" do
    test "returns their values" do
      counts = create([:a, int(10, 20), list(2)])
      |> Type.as_stream([])
      |> Stream.take(100)
      |> Enum.reduce(%{ :a => 0, :int => 0, :list => 0}, fn (val, counts) ->
        cond do
          val == :a ->
            Map.put(counts, :a, counts[:a]+1);

          is_integer(val) ->
            assert val in 10..20
            Map.put(counts, :int, counts[:int]+1);

          is_list(val) ->
           assert length(val) == 2
           Map.put(counts, :list, counts[:list]+1);

          true ->
            flunk(inspect val)
        end
      end)

      with likely_range = 20..45 do
        assert counts[:a]    in likely_range
        assert counts[:int]  in likely_range
        assert counts[:list] in likely_range
      end
    end
  end
  
end
