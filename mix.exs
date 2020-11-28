defmodule Xlack.MixProject do
  use Mix.Project

  @version "1.0.6"
  @source_url "https://github.com/GPrimola/xlack"
  @logo_path "priv/img/xlack-logo.png"
  @licenses ["Apache-2.0"]
  @description """
  This is a Slack API client for Elixir applications.
  """

  def project do
    [
      app: :xlack,
      version: "0.1.0",
      description: @description,
      elixir: "~> 1.10",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      package: package(),
      source_url: @source_url
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Xlack.Application, []}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:httpoison, "~> 1.2"},
      {:websocket_client, "~> 1.2.4"},
      {:jason, "~> 1.1"},
      {:ex_doc, "~> 0.19", only: :dev},
      {:credo, "~> 0.5", only: [:dev, :test]},
      {:plug_cowboy, "~> 1.0", only: :test},
      {:ex_machina, "~> 2.4", only: :test}
    ]
  end

  defp docs do
    [
      source_ref: "v#{@version}",
      source_url: @source_url,
      logo: @logo_path
    ]
  end

  defp package do
    [
      name: "xlack",
      description: @description,
      licenses: @licenses,
      links: %{"GitHub" => @source_url},
      files: ~w(lib priv .formatter.exs mix.exs README* LICENSE*)
    ]
  end
end
