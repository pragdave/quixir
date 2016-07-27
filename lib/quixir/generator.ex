defmodule Quixir.Generator do


  def start_link(type) do
    Agent.start_link(fn -> type end)
  end

  def stop(generator) do
    Agent.stop(generator)
  end

  def next_value(generator) do
    Agent.get_and_update(generator, Quixir.Type, :next_value, [])
  end

end
