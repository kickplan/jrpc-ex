defmodule JRPC.ErrorTest do
  use ExUnit.Case, async: true

  alias JRPC.Error

  defmodule Example.Error do
    defexception [:code, :message, :data]
  end

  test "uses the fields from the exception" do
    error = %Example.Error{code: 10, message: "Whoops", data: %{foo: "bar"}}

    assert 10 == Error.code(error)
    assert "Whoops" == Error.message(error)
    assert %{foo: "bar"} == Error.data(error)
  end

  test "uses defaults from InternalError" do
    error = %{}

    assert -32_603 == Error.code(error)
    assert "Internal error" == Error.message(error)
    assert nil == Error.data(error)
  end
end
