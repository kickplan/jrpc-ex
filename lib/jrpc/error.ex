defmodule JRPC.Error do
  @moduledoc """
  Abstract jRPC error behavior.

  See specification for pre-defined error codes and messages:
  https://www.jsonrpc.org/specification#request_object
  """

  defmacro __using__(opts) do
    code = Keyword.get(opts, :code) || raise "expects a :code to be given"
    message = Keyword.get(opts, :message) || raise "error expects a :message to be given"

    quote do
      defexception [:data, code: unquote(code), message: unquote(message)]

      @type t :: %__MODULE__{
              code: integer,
              message: String.t()
            }
    end
  end
end
