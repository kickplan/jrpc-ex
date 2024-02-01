defprotocol JRPC.Error do
  @moduledoc """
  A protocol that extends exceptions to be rpc-code aware.

  By default, it looks for an implementation of the protocol,
  otherwise checks if the exception has the `:code`, `:message`,
  and `:data` fields, or returns defaults for an Internal Error.
  """

  @fallback_to_any true

  @type code :: integer
  @type message :: binary
  @type data :: any | nil

  @doc """
  Receives an exception and returns its JRPC error code.
  """
  @spec code(t) :: code
  def code(exception)

  @doc """
  Receives an exception and returns its JRPC error message.
  """
  @spec message(t) :: message
  def message(exception)

  @doc """
  Receives an exception and returns an arbitrary set of
  data to be embedded into the error.
  """
  @spec data(t) :: data
  def data(exception)
end

defimpl JRPC.Error, for: Any do
  def code(%{code: code}), do: code
  def code(_), do: -32_603

  def message(%{message: message}), do: message
  def message(_), do: "Internal error"

  def data(%{data: data}), do: data
  def data(_), do: nil
end

defmodule JRPC.ParseError do
  @moduledoc """
  Invalid JSON was received by the server.
  An error occurred on the server while parsing the JSON text.
  """

  defexception code: -32_700, message: "Parse error"
end

defmodule JRPC.InternalError do
  @moduledoc """
  Internal JSON-RPC error.
  """

  defexception code: -32_603, message: "Internal error"
end

defmodule JRPC.InvalidParamsError do
  @moduledoc """
  Invalid method parameter(s).
  """

  defexception code: -32_602, message: "Invalid params"
end

defmodule JRPC.MethodNotFoundError do
  @moduledoc """
  The method does not exist / is not available.
  """

  defexception code: -32_601, message: "Method not found"
end

defmodule JRPC.InvalidRequestError do
  @moduledoc """
  The JSON sent is not a valid Request object.
  """

  defexception code: -32_600, message: "Invalid request"
end

defmodule JRPC.ServerError do
  @moduledoc """
  Reserved for implementation-defined server-errors.
  """

  defexception code: -32_000, message: "Server error"
end
