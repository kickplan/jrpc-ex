defmodule JRPC.RouterTest do
  # @todo Add example docs to modules and use `doctest`
  use ExUnit.Case, async: true

  alias JRPC.Response

  defmodule Example do
    def rpc(method, params \\ nil) do
      %{
        "jsonrpc" => "2.0",
        "id" => System.unique_integer([:positive, :monotonic]),
        "method" => method,
        "params" => params
      }
    end
  end

  defmodule Example.Handler do
    use JRPC.Handler

    def no_args(ctx), do: add_result(ctx, :success)
    def scalar_arg(ctx, id), do: add_result(ctx, id + 5)
    def map_arg(ctx, %{"ids" => ids}), do: add_result(ctx, ids)
    def list_args(ctx, one, two), do: add_result(ctx, [two, one])

    def with_assigns(%{assigns: assigns} = ctx, id) do
      add_result(ctx, [Map.get(assigns, :name), id])
    end

    def with_ok_return(_ctx) do
      {:ok, :success}
    end

    def with_error_return(_ctx) do
      {:error, %RuntimeError{}}
    end

    def with_exception(_ctx) do
      raise "An error occurred"
    end
  end

  defmodule Example.Router do
    use JRPC.Router, init_mode: :runtime

    rpc "ex.none", Example.Handler, :no_args
    rpc "ex.scalar", Example.Handler, :scalar_arg
    rpc "ex.map", Example.Handler, :map_arg
    rpc "ex.list", Example.Handler, :list_args
    rpc "ex.assigns", Example.Handler, :with_assigns
    rpc "ex.ok_return", Example.Handler, :with_ok_return
    rpc "ex.error_return", Example.Handler, :with_error_return
    rpc "ex.exception", Example.Handler, :with_exception
  end

  describe "handle/2" do
    test "dispatches the correct procedure and wraps the response" do
      rpc = Example.rpc("ex.none")
      assert %Response{result: :success} = Example.Router.handle(rpc)

      rpc = Example.rpc("ex.scalar", 10)
      assert %Response{result: 15} = Example.Router.handle(rpc)

      rpc = Example.rpc("ex.map", %{"ids" => [1, 2, 3]})
      assert %Response{result: [1, 2, 3]} = Example.Router.handle(rpc)

      rpc = Example.rpc("ex.list", [1, 2])
      assert %Response{result: [2, 1]} = Example.Router.handle(rpc)

      rpc = Example.rpc("ex.assigns", 5)

      assert %Response{result: ["John", 5]} =
               Example.Router.handle(rpc, %{name: "John"})
    end

    test "accepts `{:ok, result}` as a return value" do
      rpc = Example.rpc("ex.ok_return")
      assert %Response{result: :success} = Example.Router.handle(rpc)
    end

    test "accepts `{:error, error}` as a return value" do
      rpc = Example.rpc("ex.error_return")
      assert %Response{error: %{}} = Example.Router.handle(rpc)
    end

    test "populates the response id" do
      rpc = Example.rpc("ex.none")
      rpc_id = rpc["id"]
      assert %Response{id: ^rpc_id} = Example.Router.handle(rpc)

      rpc = Example.rpc("ex.none") |> Map.delete("id")
      assert %Response{id: nil} = Example.Router.handle(rpc)
    end

    test "returns a InvalidRequest error when invalid request" do
      rpc = Example.rpc("ex.none") |> Map.delete("jsonrpc")

      assert %Response{result: nil, error: error} =
               Example.Router.handle(rpc)

      assert -32_600 = error.code
      assert "Invalid request" = error.message
    end

    test "returns a MethodNotFound error when invalid method" do
      rpc = Example.rpc("ex.invalid")

      assert %Response{result: nil, error: error} =
               Example.Router.handle(rpc)

      assert -32_601 = error.code
      assert "Method not found" = error.message
    end

    test "returns a InvalidParams error with invalid params" do
      rpc = Example.rpc("ex.none", 10)

      assert %Response{result: nil, error: error} =
               Example.Router.handle(rpc)

      assert -32_602 = error.code
      assert "Invalid params" = error.message

      rpc = Example.rpc("ex.map", %{"key" => "invalid"})

      assert %Response{result: nil, error: error} =
               Example.Router.handle(rpc)

      assert -32_602 = error.code
      assert "Invalid params" = error.message
    end

    test "returns a InternalError when the rpc fails" do
      rpc = Example.rpc("ex.exception")

      assert %Response{result: nil, error: error} =
               Example.Router.handle(rpc)

      assert -32_603 = error.code
      assert "An error occurred" = error.message
    end
  end
end
