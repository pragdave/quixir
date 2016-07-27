defmodule Quixir.Constraints do

  defstruct min: 0, max: 1, must_have: nil

end


# Enum.each(1..100, fn (_) ->
#   with r = :rand.normal(), n = r * r * r * r * 1_000_000 do
#     if abs(n) < 100 do
#     IO.puts Float.round(n)
#     end
#   end
# end)
