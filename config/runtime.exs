import Config
import Dotenvy

source!([".env", System.get_env()])

config :bees_with_scope, BeesWithScope.Hive,
  app_token: env!("SLACK_APP_TOKEN", :string),
  bot_token: env!("SLACK_BOT_TOKEN", :string),
  bot: BeesWithScope.Hive

config :bees_with_scope, :port, env!("PORT", :integer, 4000)
