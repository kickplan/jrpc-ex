defmodule JRPC do
  @moduledoc false

  alias JRPC.{Errors, Request, Response}

  @type error ::
          Errors.InternalError.t()
          | Errors.InvalidParams.t()
          | Errors.InvalidRequest.t()
          | Errors.MethodNotFound.t()
          | Errors.ParseError.t()
          | Errors.ServerError.t()

  @type request :: Request.t()
  @type response :: Response.t()

  def errors() do
    # @todo Add an error registry so these aren't explicit
    [
      Errors.InternalError,
      Errors.InvalidParams,
      Errors.InvalidRequest,
      Errors.MethodNotFound,
      Errors.ParseError,
      Errors.ServerError
    ]
  end
end
