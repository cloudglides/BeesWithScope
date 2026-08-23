defmodule BeesWithScope.Workflow do
  @channel "C08TLJR2HD1"

  def post(name, api \\ Slack.API) do
    bot_token = Application.fetch_env!(:bees_with_scope, BeesWithScope.Hive)[:bot_token]

    api.post("chat.postMessage", bot_token, %{
      channel: @channel,
      text: "#{name} — click to join",
      blocks: Jason.encode!(blocks(name))
    })
  end

  def blocks(name) do
    [
      section_block(name),
      actions_block()
    ]
  end

  defp section_block(name) do
    %{
      type: "section",
      text: %{type: "mrkdwn", text: "*#{name}*"}
    }
  end

  defp actions_block do
    %{
      type: "actions",
      elements: [
        %{
          type: "button",
          style: "primary",
          action_id: "join_channel",
          text: %{type: "plain_text", text: "Join", emoji: true}
        }
      ]
    }
  end
end
