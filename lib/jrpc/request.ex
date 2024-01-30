defmodule JRPC.Request do
  @moduledoc false

  @type id :: binary | number | nil
  @type method :: binary
  @type params :: [term] | map | nil

  @type t :: %__MODULE__{
          jsonrpc: binary,
          id: id,
          method: method,
          params: params,
          valid?: boolean
        }

  defstruct [:jsonrpc, :id, :method, :params, valid?: true]

  def build(req) do
    %__MODULE__{
      jsonrpc: Map.get(req, "jsonrpc"),
      id: Map.get(req, "id"),
      method: Map.get(req, "method"),
      params: Map.get(req, "params", %{})
    }
    |> validate_id()
    |> validate_version()
  end

  defp validate_id(%{id: id} = request)
       when is_nil(id) or is_binary(id) or is_number(id),
       do: request

  defp validate_id(request), do: invalid(request)

  defp validate_version(%{jsonrpc: "2.0"} = request), do: request
  defp validate_version(request), do: invalid(request)

  defp invalid(request) do
    %{request | valid?: false}
  end
end
