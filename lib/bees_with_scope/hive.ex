defmodule BeesWithScope.Hive do
  use Slack.Bot
  require Logger

  import BeesWithScope.Parser, only: [parse: 1]
  import BeesWithScope.GHAuth, only: [fetch_pr: 3]
  import BeesWithScope.Poster, only: [build: 4]

  @impl true
  def handle_event("message", %{"bot_id" => _}, _bot), do: :ok

  def handle_event("message", %{"text" => text, "channel" => channel}, _bot) do
    dispatch(text, channel)
  end

  def handle_event("block_actions", payload, _bot), do: handle_block_actions(payload)

  def handle_event("link_shared", event, _bot) do
    case BeesWithScope.Unfurl.handle(event) do
      {:ok, _} ->
        Logger.info("Unfurled workflow link")
        :ok

      :ok ->
        :ok

      {:error, reason} ->
        Logger.error("Failed to unfurl: #{inspect(reason)}")
    end
  end

  def handle_event(_type, _payload, _bot), do: :ok

  def handle_block_actions(payload, invite \\ &BeesWithScope.Inviter.invite/1)

  def handle_block_actions(
        %{"user" => %{"id" => user_id}, "actions" => actions} = payload,
        invite
      ) do
    if Enum.any?(actions, &(&1["action_id"] == "join_channel")) do
      case invite.(user_id) do
        :ok ->
          Logger.info("Invited #{user_id} to channel")

          :ok

        {:error, reason} ->
          Logger.error("Failed to invite #{user_id}: #{inspect(reason)}")
      end
    else
      Logger.debug("Ignoring action in #{inspect(payload["channel"])}")
    end

    :ok
  end

  defp dispatch(text, channel) do
    case parse(text) do
      {:ok, %{owner: owner, repo: repo, number: number}} ->
        post_pr(channel, owner, repo, number)

      :error ->
        :ok
    end
  end

  defp post_pr(channel, owner, repo, number) do
    case fetch_pr(owner, repo, number) do
      {:ok, pr} ->
        Logger.info("Matched: #{owner}/#{repo}##{number}")
        send_message(channel, %{blocks: Jason.encode!(build(owner, repo, number, pr))})

      {:error, reason} ->
        Logger.error("Failed to fetch PR: #{inspect(reason)}")
    end
  end
end
