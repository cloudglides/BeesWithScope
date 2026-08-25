import Config
import Dotenvy

source!([".env", System.get_env()])

if config_env() == :test do
  config :bees_with_scope, BeesWithScope.Slack.Bot,
    app_token: "test-app-token",
    bot_token: "test-bot-token",
    bot: BeesWithScope.Slack.Bot

  config :bees_with_scope, :port, 4000
  config :bees_with_scope, :channel, "C_TEST"
  config :bees_with_scope, :unfurl_domains, ["cloudglides.hackclub.app"]
else
  config :bees_with_scope, BeesWithScope.Slack.Bot,
    app_token: env!("SLACK_APP_TOKEN", :string),
    bot_token: env!("SLACK_BOT_TOKEN", :string),
    bot: BeesWithScope.Slack.Bot

  config :bees_with_scope, :port, env!("PORT", :integer, 4000)
  config :bees_with_scope, :channel, env!("WORKFLOW_CHANNEL", :string)

  config :bees_with_scope,
         :unfurl_domains,
         env!("UNFURL_DOMAINS", :string, "cloudglides.hackclub.app")
         |> String.split(",", trim: true)
         |> Enum.map(&String.trim/1)
end
