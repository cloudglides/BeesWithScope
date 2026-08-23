defmodule BeesWithScope.Unfurl do
  @default_domains ["cloudglides.hackclub.app"]

  def domains do
    Application.get_env(:bees_with_scope, :unfurl_domains, @default_domains)
  end

  def workflow_name(url) do
    uri = URI.parse(url)

    if uri.host in domains() do
      case Regex.run(~r{^/workflow/([\w-]+)}, uri.path || "") do
        [_full, name] -> name
        _ -> nil
      end
    end
  end

  def handle(event, api \\ Slack.API)

  def handle(%{"links" => links, "message_ts" => ts, "channel" => channel}, api) do
    bot_token = Application.fetch_env!(:bees_with_scope, BeesWithScope.Hive)[:bot_token]

    unfurls =
      for link <- links,
          url = link["url"],
          name = workflow_name(url),
          into: %{} do
        {url, %{"blocks" => BeesWithScope.Workflow.blocks(name)}}
      end

    if map_size(unfurls) > 0 do
      api.post("chat.unfurl", bot_token, %{
        channel: channel,
        ts: ts,
        unfurls: Jason.encode!(unfurls)
      })
    end

    :ok
  end
end
