defmodule JRPC do
  @moduledoc false

  alias JRPC.{Error, Request, Response}

  @type error :: %{
          :code => Error.code(),
          :message => Error.message(),
          optional(:data) => Error.data()
        }

  @type request :: Request.t()
  @type response :: Response.t()
end
