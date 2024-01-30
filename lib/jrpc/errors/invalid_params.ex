defmodule JRPC.Errors.InvalidParams do
  @moduledoc """
  Invalid method parameter(s).
  """

  use JRPC.Error,
    code: -32_602,
    message: "Invalid params"
end
