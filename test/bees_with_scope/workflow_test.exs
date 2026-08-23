defmodule BeesWithScope.WorkflowTest do
  use ExUnit.Case

  alias BeesWithScope.Workflow

  defmodule StubAPI do
    def post(endpoint, token, args) do
      send(self(), {:api_post, endpoint, token, args})
      {:ok, %{"ok" => true}}
    end
  end

  setup do
    Application.put_env(:bees_with_scope, BeesWithScope.Hive, bot_token: "xoxb-test")
    :ok
  end

  test "blocks contain a join button for the workflow" do
    assert [
             %{type: "section", text: %{type: "mrkdwn", text: text}},
             %{type: "actions", elements: [button]}
           ] = Workflow.blocks("kidnap")

    assert text =~ "*kidnap*"

    assert button == %{
             type: "button",
             style: "primary",
             action_id: "join_channel",
             text: %{type: "plain_text", text: "Join", emoji: true}
           }
  end

  test "post sends the blocks to the channel with the bot token" do
    assert Workflow.post("kidnap", StubAPI) == {:ok, %{"ok" => true}}

    assert_received {:api_post, "chat.postMessage", "xoxb-test", args}
    assert args.channel == "C08TLJR2HD1"
    assert Jason.decode!(args.blocks) == Jason.decode!(Jason.encode!(Workflow.blocks("kidnap")))
  end
end
