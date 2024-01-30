defmodule JRPC.Router.Route do
  @moduledoc false

  defstruct [:line, :module, :method, :plug, :plug_opts]
end
