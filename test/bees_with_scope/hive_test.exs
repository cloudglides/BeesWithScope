defmodule BeesWithScope.HiveTest do
  use ExUnit.Case

  alias BeesWithScope.Hive

  @payload %{
    "type" => "block_actions",
    "user" => %{"id" => "U_CLICKER"},
    "channel" => %{"id" => "C_ORIG"},
    "actions" => [%{"action_id" => "join_channel", "type" => "button"}]
  }

  test "join_channel button click invites the clicking user" do
    parent = self()

    assert :ok =
             Hive.handle_block_actions(@payload, fn user_id ->
               send(parent, {:invited, user_id})
               :ok
             end)

    assert_received {:invited, "U_CLICKER"}
  end

  test "other buttons are ignored" do
    payload = put_in(@payload, ["actions"], [%{"action_id" => "something_else"}])

    assert :ok = Hive.handle_block_actions(payload, fn _user_id -> flunk("should not invite") end)
  end
end
