defmodule BeesWithScope.MixProject do
  use Mix.Project

  def project do
    [
      app: :bees_with_scope,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: releases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {BeesWithScope.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp releases do
    [
      bees_with_scope: []
    ]
  end

  defp deps do
    [
      {:slack_elixir, path: "vendor/slack_elixir"},
      {:dotenvy, "~> 0.8.0"},
      {:req, "~> 0.5.0"},
      {:bandit, "~> 1.0"},
      {:plug, "~> 1.16"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
