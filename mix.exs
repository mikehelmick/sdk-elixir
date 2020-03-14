defmodule Cloudevents.MixProject do
  use Mix.Project

  def project do
    [
      app: :cloudevents,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:earmark, "~> 1.4", only: :dev},
      {:dialyxir, "~> 0.5.1", only: [:dev]},
      {:content_type, "~> 0.1.0"},
      {:accessible, "~> 0.2.1"},
      {:poison, "~> 4.0"},
      {:httpoison, "~> 1.6"},
      {:plug_cowboy, "~> 2.1"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
