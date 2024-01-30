defmodule JRPC.Errors.MethodNotFound do
  @moduledoc """
  The method does not exist / is not available.
  """

  use JRPC.Error,
    code: -32_601,
    message: "Method not found"
end
