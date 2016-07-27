
defmodule Pbt.Generator.Int do

  def values(%Pbt.GenParams{min: min, max: max}) when max > min do
    Stream.unfold(nil, fn nil ->
      { (max - min)*:random.uniform() + min, nil }
    end)
  end

  defmacro props(e,d) do
    IO.inspect e
    IO.puts "-----"
    IO.inspect d
    true
  end
end

defmodule X do
  require Pbt.Generator.Int
  import Pbt.Generator.Int

  props p: int(1234), j: string do

  end
#props {i,j, k} <- {1..10, string(length: 10), [:a, :b]} do

end
