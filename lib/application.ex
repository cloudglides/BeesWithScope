defmodule BeesWithScope.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children =
      if Application.get_env(:bees_with_scope, :start_slack, true) do
        [{Slack.Supervisor, Application.fetch_env!(:bees_with_scope, BeesWithScope.Slack.Bot)}]
      else
        []
      end

    children =
      if Application.get_env(:bees_with_scope, :start_web, true) do
        children ++
          [
            {Bandit,
             plug: BeesWithScope.Web.Router, port: Application.fetch_env!(:bees_with_scope, :port)}
          ]
      else
        children
      end

    opts = [strategy: :one_for_one, name: BeesWithScope.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
