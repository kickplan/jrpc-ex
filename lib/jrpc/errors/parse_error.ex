defmodule JRPC.Errors.ParseError do
  @moduledoc """
  Invalid JSON was received by the server.
  An error occurred on the server while parsing the JSON text.
  """

  use JRPC.Error,
    code: -32_700,
    message: "Parse error"
end
