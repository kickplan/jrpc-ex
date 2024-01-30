defmodule JRPC.Errors.ServerError do
  @moduledoc """
  Reserved for implementation-defined server-errors.
  """

  use JRPC.Error,
    code: -32_000,
    message: "Server error"
end
