defmodule BeesWithScope.Slack.UnfurlTest do
  use ExUnit.Case

  alias BeesWithScope.Slack.Unfurl

  defmodule StubAPI do
    def post(endpoint, token, args) do
      send(self(), {:api_post, endpoint, token, args})
      {:ok, %{"ok" => true}}
    end
  end

  setup do
    Application.put_env(:bees_with_scope, BeesWithScope.Slack.Bot, bot_token: "xoxb-test")
    Application.put_env(:bees_with_scope, :unfurl_domains, ["cloudglides.hackclub.app"])

    on_exit(fn ->
      Application.delete_env(:bees_with_scope, :unfurl_domains)
    end)

    :ok
  end

  describe "workflow_name/1" do
    test "extracts the workflow name from a matching domain" do
      assert Unfurl.workflow_name("http://cloudglides.hackclub.app:4000/workflow/kidnap") ==
               "kidnap"

      assert Unfurl.workflow_name("https://cloudglides.hackclub.app/workflow/kidnap") == "kidnap"
    end

    test "ignores other domains" do
      assert Unfurl.workflow_name("https://evil.com/workflow/kidnap") == nil
      assert Unfurl.workflow_name("http://localhost:4000/workflow/kidnap") == nil
    end

    test "ignores non-workflow paths" do
      assert Unfurl.workflow_name("http://cloudglides.hackclub.app/nope") == nil
    end
  end

  test "link_shared event unfurls with a join button" do
    Application.put_env(:bees_with_scope, BeesWithScope.Slack.Bot, bot_token: "xoxb-test")

    event = %{
      "type" => "link_shared",
      "channel" => "C_DMS",
      "message_ts" => "1234.5678",
      "links" => [
        %{
          "domain" => "cloudglides.hackclub.app",
          "url" => "http://cloudglides.hackclub.app:4000/workflow/kidnap"
        }
      ]
    }

    assert Unfurl.handle(event, StubAPI) == :ok

    assert_received {:api_post, "chat.unfurl", "xoxb-test", args}
    assert args.channel == "C_DMS"
    assert args.ts == "1234.5678"

    unfurls = Jason.decode!(args.unfurls)
    assert Map.has_key?(unfurls, "http://cloudglides.hackclub.app:4000/workflow/kidnap")

    [entry] = unfurls |> Map.values()

    assert [%{"type" => "section"}, %{"type" => "actions"}] = entry["blocks"]
  end

  test "link_shared with unrelated links does nothing" do
    event = %{
      "type" => "link_shared",
      "channel" => "C_DMS",
      "message_ts" => "1234.5678",
      "links" => [%{"domain" => "example.com", "url" => "https://example.com/foo"}]
    }

    assert Unfurl.handle(event, StubAPI) == :ok

    refute_received {:api_post, _, _, _}
  end
end
