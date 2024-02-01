defmodule JRPC.Handler do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      import JRPC.Context, except: [init: 2]
      import JRPC.Handler

      alias JRPC.Context
    end
  end

  # @todo Add "controller"-like methods (eg. render(), etc.)
end
