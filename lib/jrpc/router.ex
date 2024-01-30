defmodule JRPC.Router do
  @moduledoc false

  alias __MODULE__, as: Router
  alias Router.Route
  alias JRPC.{Context, Errors}

  import Context, only: [add_error: 2]

  @doc false
  defmacro __using__(opts) do
    quote do
      unquote(prelude())
      unquote(pipeline(opts))
    end
  end

  defp prelude() do
    quote do
      import Router
      import Context, except: [init: 1]

      Module.register_attribute(__MODULE__, :jrpc_routes, accumulate: true)

      def call(ctx), do: call(ctx, nil)

      def handle(req, assigns \\ %{}),
        do: Router.__handle__(__MODULE__, req, assigns)

      @before_compile Router
    end
  end

  defp pipeline(opts) do
    quote location: :keep, generated: true do
      use Pluggable.StepBuilder, unquote(opts)

      step :validate
      step :match
      step :dispatch

      def dispatch(ctx, _opts), do: Router.__dispatch__(ctx)
      def match(ctx, _opts), do: Router.__match__(ctx, __MODULE__)
      def validate(ctx, _opts), do: Router.__validate__(ctx)

      defoverridable dispatch: 2, match: 2, validate: 2
    end
  end

  def __handle__(pipeline, req, assigns) do
    Context.init(req, assigns)
    |> pipeline.call()
    |> Map.get(:response)
  end

  def __dispatch__(%Context{route: route, request: request} = ctx) do
    plug_args = [ctx] ++ List.wrap(request.params)
    apply(route.plug, route.plug_opts, plug_args)
  rescue
    UndefinedFunctionError ->
      add_error(ctx, %Errors.InvalidParams{})

    e ->
      # TODO Add logging for these errors
      add_error(ctx, %Errors.InternalError{data: e.message})
  end

  def __match__(%Context{request: request} = ctx, router) do
    case router.__match_route__(request.method) do
      :error ->
        add_error(ctx, %Errors.MethodNotFound{})

      route ->
        %{ctx | route: route}
    end
  end

  def __validate__(%Context{request: %{valid?: false}} = ctx) do
    add_error(ctx, %Errors.InvalidRequest{})
  end

  def __validate__(%Context{} = ctx), do: ctx

  defmacro rpc(method, plug, plug_opts) do
    quote do
      @jrpc_routes %Route{
        line: __ENV__.line,
        module: __ENV__.module,
        method: unquote(method),
        plug: unquote(plug),
        plug_opts: unquote(plug_opts)
      }
    end
  end

  defmacro __before_compile__(env) do
    routes = Module.get_attribute(env.module, :jrpc_routes)

    matches =
      Enum.map(routes, &build_match/1)

    match_catch_all =
      quote generated: true do
        def __match_route__(_), do: :error
      end

    quote do
      def __routes__, do: unquote(Macro.escape(routes))

      unquote(matches)
      unquote(match_catch_all)
    end
  end

  defp build_match(route) do
    quote line: route.line do
      def __match_route__(unquote(route.method)) do
        unquote(Macro.escape(route))
      end
    end
  end
end
