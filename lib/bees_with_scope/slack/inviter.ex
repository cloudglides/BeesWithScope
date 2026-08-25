defmodule BeesWithScope.Slack.Inviter do
  def invite(user_id, api \\ Slack.API) do
    bot_token = Application.fetch_env!(:bees_with_scope, BeesWithScope.Slack.Bot)[:bot_token]
    channel = Application.fetch_env!(:bees_with_scope, :channel)

    case api.post("conversations.invite", bot_token, %{channel: channel, users: user_id}) do
      {:ok, _body} ->
        :ok

      {:error, %{body: %{"error" => "already_in_channel"}}} ->
        :ok

      {:error, reason} ->
        {:error, reason}
    end
  end
end
