ExUnit.start()

defmodule Quixir.PropertyError do
  defexception [ :message ]
end

defmodule Quixir.Shrinker do

  use ExUnit.Case


  def shrink(env = {_code, state, locals}) do
    # see if it fails initially. If so, start the shrinking
    try_to_run(env, ok: &unexpected_pass/1, fail: &start_shrink/1)
  end

  defp try_to_run(env = {code, state, locals}, ok: passed, fail: failed) do
    if code.(locals) do
      passed.(env)
    else
      failed.(env)
    end
  end

  defp unexpected_pass(_env) do
    raise "The code unexpectedly passed the second time it was run"
  end

  defp start_shrink(env = {_code, state, _locals}) do
    pending = Map.keys(state)
    try_to_shrink(env, pending)
    raise "failed"
  end

  # Here we've exhausted all possible shrinking, so we're done
  defp try_to_shrink({_code, _state, locals}, []) do
    vars = locals
    |> Enum.map(fn {name, val} -> "#{name} = #{inspect val}" end)
    |> Enum.join(", ")

    raise Quixir.PropertyError, "when: #{vars}"
  end

  # shrink by adjusting the first value until it adjusts no more…
  # record the final value of that first parameter, and then move on
  # to the second
  defp try_to_shrink(env = { code, state, locals }, [ current | rest ]) do
    val = Pollution.Shrinker.shrink_until_done(current, env)
    new_locals = %{ locals | current => val }
    try_to_shrink({code, state, new_locals}, rest)
  end

end
