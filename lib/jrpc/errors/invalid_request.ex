defmodule JRPC.Errors.InvalidRequest do
  @moduledoc """
  The JSON sent is not a valid Request object.
  """

  use JRPC.Error,
    code: -32_600,
    message: "Invalid request"
end
