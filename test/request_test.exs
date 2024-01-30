defmodule JRPC.RequestTest do
  # TODO Add example docs to modules and use `doctest`
  use ExUnit.Case, async: true

  alias JRPC.Request

  setup do
    rpc = %{
      "jsonrpc" => "2.0",
      "id" => "1234",
      "method" => "example.method",
      "params" => ["foo", "bar"]
    }

    [rpc: rpc]
  end

  describe "build/1" do
    test "builds a %Request{}", %{rpc: rpc} do
      request = %Request{
        jsonrpc: "2.0",
        id: rpc["id"],
        method: rpc["method"],
        params: rpc["params"],
        valid?: true
      }

      assert ^request = Request.build(rpc)
    end

    test "validates the id", %{rpc: rpc} do
      assert %Request{valid?: true} =
               Request.build(%{rpc | "id" => nil})

      assert %Request{valid?: true} =
               Request.build(%{rpc | "id" => 123})

      assert %Request{valid?: false} =
               Request.build(%{rpc | "id" => []})
    end

    test "validates the version", %{rpc: rpc} do
      assert %Request{valid?: false} =
               Request.build(%{rpc | "jsonrpc" => "invalid"})
    end
  end
end
