defmodule BeesWithScope.InviterTest do
  use ExUnit.Case

  alias BeesWithScope.Inviter

  defmodule StubAPI do
    def post(endpoint, token, args) do
      send(self(), {:api_post, endpoint, token, args})
      {:ok, %{"ok" => true}}
    end
  end

  defmodule AlreadyInAPI do
    def post(_endpoint, _token, _args) do
      {:error, %{status: 200, body: %{"ok" => false, "error" => "already_in_channel"}}}
    end
  end

  defmodule FailingAPI do
    def post(_endpoint, _token, _args) do
      {:error, %{status: 403, body: %{"ok" => false, "error" => "missing_scope"}}}
    end
  end

  setup do
    Application.put_env(:bees_with_scope, BeesWithScope.Hive, bot_token: "xoxb-test")
    Application.put_env(:bees_with_scope, :channel, "C_TEST")

    on_exit(fn ->
      Application.delete_env(:bees_with_scope, :channel)
    end)

    :ok
  end

  test "invites the user to the configured channel" do
    assert Inviter.invite("U_CLICKER", StubAPI) == :ok

    assert_received {:api_post, "conversations.invite", "xoxb-test",
                     %{
                       channel: "C_TEST",
                       users: "U_CLICKER"
                     }}
  end

  test "users already in the channel are not errors" do
    assert Inviter.invite("U_CLICKER", AlreadyInAPI) == :ok
  end

  test "other failures pass through as errors" do
    assert {:error, %{body: %{"error" => "missing_scope"}}} =
             Inviter.invite("U_CLICKER", FailingAPI)
  end
end
