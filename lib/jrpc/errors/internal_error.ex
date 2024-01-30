defmodule JRPC.Errors.InternalError do
  @moduledoc """
  Internal JSON-RPC error.
  """

  use JRPC.Error,
    code: -32_603,
    message: "Internal error"
end
