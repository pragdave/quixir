defmodule Quixir.Distribution.HyperNormal do

  def factor do
    :rand.uniform
  end

  defp sign(n) when n < 0.0, do: -1.0
  defp sign(_), do: 1.0

end
