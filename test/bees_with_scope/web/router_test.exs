defmodule BeesWithScope.Web.RouterTest do
  use ExUnit.Case, async: false

  import Plug.Conn
  import Plug.Test

  alias BeesWithScope.Web.Router

  defmodule StubWorkflow do
    def post(name) do
      send(self(), {:workflow_posted, name})
      {:ok, %{"ok" => true}}
    end
  end

  defmodule FailingWorkflow do
    def post(_name), do: {:error, :boom}
  end

  setup do
    Application.put_env(:bees_with_scope, :workflow_mod, StubWorkflow)

    on_exit(fn ->
      Application.delete_env(:bees_with_scope, :workflow_mod)
    end)

    :ok
  end

  test "POST /workflow/:name posts the workflow and returns 200" do
    conn =
      :post
      |> conn("/workflow/kidnap")
      |> Router.call(Router.init([]))

    assert conn.status == 200
    assert_received {:workflow_posted, "kidnap"}
  end

  test "GET /workflow/:name shows a landing page without posting" do
    conn =
      :get
      |> conn("/workflow/kidnap")
      |> Router.call(Router.init([]))

    assert conn.status == 200
    assert conn.resp_body =~ "kidnap"
    refute_received {:workflow_posted, _}
  end

  test "unknown routes are 404" do
    conn =
      :get
      |> conn("/nope")
      |> Router.call(Router.init([]))

    assert conn.status == 404
  end

  test "workflow failure is a 502" do
    Application.put_env(:bees_with_scope, :workflow_mod, FailingWorkflow)

    conn =
      :post
      |> conn("/workflow/kidnap")
      |> Router.call(Router.init([]))

    assert conn.status == 502
  end
end
