defmodule Quixir.Distribution.Uniform do

  def factor do
    :rand.uniform()
  end

end
