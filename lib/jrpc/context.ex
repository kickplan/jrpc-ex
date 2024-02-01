defmodule JRPC.Context do
  @moduledoc false

  alias __MODULE__, as: Context
  alias JRPC.{Error, Request, Response, Router}

  @type assigns :: %{optional(atom) => any}
  @type halted :: boolean
  @type route :: Router.route() | nil

  @type t :: %__MODULE__{
          assigns: assigns,
          halted: halted,
          request: JRPC.request(),
          response: JRPC.response(),
          route: nil
        }

  @derive Pluggable.Token
  defstruct assigns: %{},
            halted: false,
            request: nil,
            response: nil,
            route: nil

  @spec init(req :: map, assigns :: map) :: t
  def init(req, assigns \\ %{}) do
    %__MODULE__{}
    |> build_request(req)
    |> build_response()
    |> merge_assigns(assigns)
  end

  defp build_request(ctx, req) do
    %{ctx | request: Request.build(req)}
  end

  defp build_response(%{request: request} = ctx) do
    %{ctx | response: %Response{id: request.id}}
  end

  @spec add_error(t, error :: JRPC.error()) :: t
  def add_error(%{response: response} = ctx, error) do
    response = %{response | error: handle_error(error)}

    %{ctx | halted: true, response: response}
  end

  @spec add_result(t, result :: any) :: t
  def add_result(%{response: response} = ctx, result) do
    %{ctx | response: %{response | result: result}}
  end

  @spec merge_assigns(t, Enumerable.t()) :: t
  def merge_assigns(%Context{assigns: assigns} = ctx, new) do
    %{ctx | assigns: Enum.into(new, assigns)}
  end

  defp handle_error(error) do
    %{
      code: Error.code(error),
      data: Error.data(error),
      message: Error.message(error)
    }
  end
end
