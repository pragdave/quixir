defmodule Quixir do

  @moduledoc File.read!("README.md")

  defmacro __using__(_options) do
    quote do
      require Quixir.Props
      import  Quixir.Props, only: [ptest: 2, ptest: 3]
      import  Pollution.VG
    end
  end

end
