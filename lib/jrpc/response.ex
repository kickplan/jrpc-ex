defmodule JRPC.Response do
  @moduledoc false

  @type id :: JRPC.Request.id()
  @type error :: JRPC.error() | nil
  @type result :: any | nil

  @type t :: %__MODULE__{
          id: id,
          error: error,
          result: result,
          jsonrpc: binary
        }

  defstruct [:id, :error, :result, jsonrpc: "2.0"]
end
