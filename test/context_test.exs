defmodule JRPC.ContextTest do
  # TODO Add example docs to modules and use `doctest`
  use ExUnit.Case, async: true

  alias JRPC.{Context, Errors, Request, Response}

  setup do
    rpc = %{
      "jsonrpc" => "2.0",
      "id" => "1234",
      "method" => "example.method",
      "params" => ["foo", "bar"]
    }

    ctx = Context.init(rpc)

    [rpc: rpc, ctx: ctx]
  end

  describe "init/2" do
    test "builds a %Request{}", %{rpc: rpc, ctx: ctx} do
      request = Request.build(rpc)

      assert ^request = ctx.request
    end

    test "prepares a %Response{}", %{ctx: ctx} do
      assert %Response{} = ctx.response
    end

    test "merges any assigns", %{rpc: rpc} do
      ctx = Context.init(rpc, %{foo: "bar", bar: "baz"})

      assert ctx.assigns[:foo] == "bar"
      assert ctx.assigns[:bar] == "baz"
    end
  end

  describe "add_error/2" do
    test "sets the response error and halts", %{ctx: ctx} do
      ctx = Context.add_error(ctx, %Errors.InvalidRequest{})

      assert %Errors.InvalidRequest{} = ctx.response.error
      assert ctx.halted
    end
  end

  describe "add_result/2" do
    test "sets the response result", %{ctx: ctx} do
      ctx = Context.add_result(ctx, [:foo, :bar])

      assert [:foo, :bar] = ctx.response.result
    end
  end

  describe "merge_assigns/2" do
    test "merges all key/value pairs into existing assigns", %{rpc: rpc} do
      ctx =
        rpc
        |> Context.init(foo: 1, bar: 2)
        |> Context.merge_assigns(bar: 3, baz: 4)

      assert ctx.assigns[:foo] == 1
      assert ctx.assigns[:bar] == 3
      assert ctx.assigns[:baz] == 4
    end
  end
end
